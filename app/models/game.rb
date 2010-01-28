require 'state_machine'

class Game
  include ModelBasics
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :start_time, DateTime
  property :end_time, DateTime
  property :mode, String
  property :state, String
  property :replay, Text
  property :type, Discriminator
  
  #
  # Associations
  #
  belongs_to :league
  has n, :game_memberships
  has n, :players, :through => :game_memberships

  #
  # State Machine
  #
  state_machine :initial => :staged do
    state :staged
    state :running
    state :scourge_won
    state :sentinel_won
    state :aborted

    after_transition :running => any - :aborted, :do => :process_score
    after_transition :on => :start, :do => [:push_start_time,:drop_staged_players]

    event :start do
      transition :staged => :running, :if => :allowed_to_start?
    end
    event :scourge_wins do
      transition :running => :scourge_won, :if => :allowed_to_stop?
    end
    event :sentinel_wins do
      transition :running => :sentinel_won, :if => :allowed_to_stop?
    end
    event :abort do
      transition :running => :aborted
    end
    event :cancel do
      transition :staged => :aborted
    end

    state :running, :scourge_win, :sentinel_won, :aborted do
      validates_with_method :enough_players
      validates_present :mode
    end
  end

  def push_start_time
    self.start_time = DateTime.now
  end

  def drop_staged_players
    game_memberships.select{|game_membership| game_membership.party == :staged}.each(&:destroy)
  end

  def allowed_to_start?
    enough_player = enough_players
    enough_player.first && (!! mode)
  end

  def allowed_to_stop?
    true
  end

  #
  # Validations
  #

  def persistent?
    ["running", "sentinel_wins", "scourge_wins", "abort"].include? state
  end

  def enough_players
    errors_ary = []
    case sentinel.size
    when (0..4)
      errors_ary << [NotEnoughPlayers.new(self), "Not enough sentinel players. #: #{sentinel.size}."]
    when (6..1/0.0)
      errors_ary << [TooManyPlayers.new(self), "Too many sentinel players. #: #{sentinel.size}."]
    end
    case scourge.size
    when (0..4)
      errors_ary << [NotEnoughPlayers.new(self), "Not enough scourge players #: #{scourge.size}."]
    when (6..1/0.0)
      errors_ary << [TooManyPlayers.new(self), "Too many enough scourge players #: #{scourge.size}."]
    end
    [errors_ary.empty?, errors_ary]
  end

  def enough_players?
    enough_player.first
  end

  def process_score
    PlayerScore.send(Rango::AppConfig[:score_method], self).each {|player, score|
      player.league_memberships.first(:league => league).score = score
    }
  end

  #
  # Logic
  #
  default_scope(:default).update(:order => [:start_time.desc])

  def result
    case state
      when "scourge_won" then :scourge
      when "sentinel_won" then :sentinel
      when "aborted" then :aborted
      else :undecided
    end
  end

  def join(player)
    raise GameRunning.new(self) if persistent?
    allowed_to_join(player)
    players << player
    save
  end

  def leave(player)
    raise GameRunning.new(self) if persistent?
    gm(player).destroy
    game_memberships.empty? ? destroy : save
  end

  def allowed_to_join?(player)
    begin
      allowed_to_join(player)
      true
    rescue => e
      errors.add :player, e
      false
    end
  end

  def allowed_to_join(player)
    raise NotVouched.new(player, league), "#{player.login} is not vouched in #{league.name}." unless player.vouched?(league)
    raise Banned.new(player, league), "#{player.login} is banned due to #{player.bans(league).last.reason}." if player.banned?(league)
    if other_game = player.where_playing
      raise PlayerPlaying.new(player, other_game), "#{player.login} is playing in #{other_game.id}."
    end
  end

  def sentinel
    game_memberships.all(:party => :sentinel).player
  end

  def scourge
    game_memberships.all(:party => :scourge).player
  end

  def sentinel_set(player)
    party_set(player, :sentinel)
  end

  def scourge_set(player)
    party_set(player, :scourge)
  end

  def party_set(player, party)
    gm(player).party = party
    gm(player).save
  end

  def party(player)
    gm(player).party
  end

  def gm(player)
    game_memberships.first(:player => player)
  end

  def vote(player, chosen)
    raise GameNotRunning unless state == "running"
    gm = game_memberships.first(:player => player)
    gm.vote = chosen
    gm.save
    check_votes
  end

  def votes
    game_memberships.map{|gm| gm.vote}.inject(Hash.new(0)) {|hash,vote| hash[vote] +=1; hash}
  end

  def check_votes
    game_memberships.reload
    votes.each do |vote, number|
      next if number < Rango::AppConfig[:votes_needed] || vote == :none
      send(vote)
    end
  end

end

class GameException < StandardError; end
class PlayerPlaying < GameException
  def initialize(player, game)
    @player, @game = player, game
  end
  attr_reader :player, :game
end
class TooManyPlayers < GameException
  def initialize(game)
    @game = game
  end
  attr_reader :game
end
class NotEnoughPlayers < GameException
  def initialize(game)
    @game = game
  end
  attr_reader :game
end
class GameRunning < GameException
  def initialize(game)
    @game = game
  end
  attr_reader :game
end
class GameNotRunning < GameException
  def initialize(game)
    @game = game
  end
  attr_reader :game
end

class RandomGame < Game
  def random_assignment
    gms = game_memberships.all
    gms.shuffle!
    gms[0..4].each { |gm| gm.party = :sentinel; gm.save}
    gms[5..9].each { |gm| gm.party = :scourge; gm.save}
    save
  end
end

class CaptainGame < Game

  def initialize(*args)
    self.mode = Rango::AppConfig[:captain_game_mode]
    super
  end

  property :pick_next, Enum[:sentinel, :scourge], :default => proc {|r,p| r.choose_pick_next}
  has 2, :captain_memberships, 'GameMembership', :child_key => [ :game_id ], :captain => true
  has 2, :captains, 'Player', :through => :captain_memberships, :via => :player

  #
  # Validations
  #
  
  validates_with_method :allowed_to_be_captains

  def allowed_to_be_captains
    return true unless new?
    captains.all? do |capt|
      if allowed_to_join?(capt)
        league.captain?(capt)
        true
      else
        false
      end
    end
  end

  #
  # State Machine
  #

  state_machine :initial => :challenged do
    state :challenged

    event :challenge_accepted do
      transition :from => :challenged, :to => :staged
      # add timer
    end

  end

  #
  # Logic
  #
  def join_as_captain(player)
    __allowed_to_join(player)
    league.captain?(player)
    captains << player
    save
  end

  def self.direct_challenge(league, challenger, challenged)
    game = create(:league => league)
    game.join_as_captain(challenger)
    game.game_memberships.reload
    game.sentinel_set(challenger)
    game.join_as_captain(challenged)
    game.game_memberships.reload
    game.scourge_set(challenged)
    game.save
    game
  end

  def self.anonymous_challenge(league, challenger)
    game = create(:league => league)
    game.join_as_captain(challenger)
    game.game_memberships.reload
    game.sentinel_set(challenger)
    game.save
    game
  end

  def accept_challenge(player)
    if scourge.include? player
      # direct challenge
      challenge_accepted
    elsif captains.size == 1
      # anonymous challenge
      join_as_captain(player)
      distribute_captains
      challenge_accepted
    else
      raise NotChallenged.new(self), "You're not challenged."
    end
  end

  def distribute_captains
    reload
    if game_memberships.all(:player => captains).all? {|cm| cm.party == :staged}
      party1, party2 = [:sentinel, :scourge].shuffle
      party_set(captains.first,party1)
      party_set(captains.last,party2)
      save
    end
  end

  def leave(player)
    if captains.include? player
      destroy
      return true
    end
    super
    game_memberships.reload
    self.pick_next = choose_pick_next
    save
  end

  alias :__allowed_to_join :allowed_to_join
  def allowed_to_join(player)
    raise ChallengeNotAccepted.new(self) if state == "challenged"
    super
  end

  def pick(capt, player)
    unless capt.party == pick_next
      raise NotYourTurn.new(self, capt), "It's not #{capt.login}'s turn."
    else
      raise PlayerNotJoined.new(self, capt, player), "#{player.login} hasn't joined Game \##{self.id}." unless gm(player)
      if player.party == :staged
        gm(player).party = pick_next
        gm(player).save
        self.pick_next = choose_pick_next
        save
      else
        raise AlreadyPicked.new(self, capt, player), "#{player.login} has been picked."
      end
      start if allowed_to_start?
    end
  end

  def choose_pick_next
    case sentinel.size <=> scourge.size
    when -1
      :sentinel
    when 0
      [:sentinel, :scourge].sample
    when 1
      :scourge
    end
  end

  def picking_captain
    game_memberships.first(:party => pick_next).player
  end
end

class CaptainGameException < GameException; end
class NotYourTurn < CaptainGameException
  def initialize(game, captain)
    @game, @captain = game, captain
  end
  attr_reader :game, :captain
end
class AlreadyPicked < CaptainGameException
  def initialize(game, captain, player)
    @game, @captain, @player = game, captain, player
  end
  attr_reader :game, :captain, :player
end
class PlayerNotJoined < CaptainGameException
  def initialize(game, captain, player)
    @game, @captain, @player = game, captain, player
  end
  attr_reader :game, :captain, :player
end
class NotChallenged < CaptainGameException
  def initialize(captain)
    @captain = captain
  end
  attr_reader :captain
end
class ChallengeNotAccepted < CaptainGameException
  def initialize(game)
    @game = game
  end
  attr_reader :game
end
