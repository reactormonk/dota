require 'state_machine'

class Game
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :start_time, DateTime
  property :end_time, DateTime
  property :mode, String, :default => Rango::AppConfig[:game_mode]
  # errors: running, not running
  property :state, String
  property :replay, Text
  property :type, Discriminator
  
  #
  # Associations
  #
  belongs_to :league
  has n, :game_memberships
  # errors: not enough
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

  end

  def push_start_time
    self.start_time = DateTime.now
  end

  def drop_staged_players
    game_memberships.select{|game_membership| game_membership.party == :staged}.each(&:destroy)
  end

  def allowed_to_stop?
    true
  end

  #
  # Validations
  #

  validates_with_method :enough_players, :if => :persistent?
  validates_present :mode, :if => :persistent?

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

  def sentinel
    game_memberships.all(:party => :sentinel).player
  end

  def scourge
    game_memberships.all(:party => :scourge).player
  end

  def gm(player)
    game_memberships.first(:player => player)
  end

  def check_votes
    game_memberships.reload
  end

end

class RandomGame < Game
  def random_assignment
    gms = game_memberships.all
    gms.shuffle!
    gms[0..4].each { |gm| gm.party = :sentinel; gm.save}
    gms[5..9].each { |gm| gm.party = :scourge; gm.save}
  end
end

class CaptainGame < Game

  def initialize(*args)
    super
    self.mode = Rango::AppConfig[:captain_game_mode]
  end

  has 2, :captain_memberships, 'GameMembership', :child_key => [ :game_id ], :captain => true
  has 2, :captains, 'Player', :through => :captain_memberships, :via => :player

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
  def self.direct_challenge(league, challenger, challenged)
    game = anonymous_challenge(league, challenger)
    gm_scourge = game.game_memberships.new
    gm_scourge.attributes = {party: :scourge, player: challenged, captain: true}
    game
  end

  def self.anonymous_challenge(league, challenger)
    game = create(:league => league)
    gm_sentinel = game.game_memberships.new
    gm_sentinel.attributes = {party: :sentinel, player: challenger, captain: true}
    game
  end

  def pick(capt, player)
    gm = gm(player)
    gm.party = pick_next
    gm.picked = true
  end
end
