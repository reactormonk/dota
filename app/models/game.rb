require 'state_machine'

class Game
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

    event :start do
      transition :from => :staged, :to => :running, :if => :allowed_to_start?
      start_time = DateTime.now
    end
    event :scourge_wins do
      transition :from => :running, :to => :scourge_won
    end
    event :sentinel_wins do
      transition :from => :running, :to => :sentinel_won
    end
    event :abort do
      transition :from => :running, :to => :aborted
    end
    event :cancel do
      transition :from => :staged, :to => :aborted
    end
  end

  def allowed_to_start?
    valid?(:starting)
  end

  def allowed_to_stop?
  end

  #
  # Validations
  #
  validates_with_method :enough_players?, :when => [:starting]
  validates_present :mode, :when => [:starting]

  def enough_players?
    unless players.all.select{|player| player.party == :sentinel}.size == 5
      errors << "Not enough sentinel players."
    end
    unless players.all.select{|player| player.party == :scourge}.size == 5
      errors << "Not enough scourge players."
    end
    errors ? [false, errors.join(" ")] : true
  end

  #
  # Logic
  #
  default_scope(:default).update(:order => [:start_time.desc])

  def result
    case state
      when :scourge_won then :scourge
      when :sentinel_won then :sentinel
      when :aborted then :aborted
      else :undecided
    end
  end

  def join(player)
    allowed_to_join(player)
    players << player
    save
  end

  def leave(player)
    gm(player).destroy
    destroy if game_memberships.size == 0
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
    raise NotVouched, "#{player} is not vouched in #{league}." unless player.is_vouched?(league)
    raise Banned, "#{player} is banned due to #{player.bans(league).last}." if player.is_banned?(league)
    raise PlayerPlaying, "#{player} is playing in #{player.where_playing}." if player.is_playing?
  end

  def sentinel
    game_memberships.all(:party => :sentinel)
  end

  def scourge
    game_memberships.all(:party => :scourge)
  end

  def sentinel_set(player)
    party_set(player, :sentinel)
  end

  def scourge_set(player)
    party_set(player, :scourge)
  end

  def party_set(player, party)
    gm(player).party = party
  end

  def gm(player)
    game_memberships.first(:player => player)
  end
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
        # add other checks here
        true
      else
        false
      end
    end
  end

  #
  # State Machine
  #

  state_machine :default => :challenged do
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
    allowed_to_join(player)
    captains << player
    save
  end

  def challenges(challenger, challenged)
    raise "Use only to initialize" unless captains.size == 0 and players.size == 0
    join_as_captain(challenger)
    reload  # I don't like this, but it seems to be needed due to DataMapper
            # not tracking intermediates correctly
    sentinel_set(challenger)
    join_as_captain(challenged)
    reload
    scourge_set(challenged)
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
      save
      return true
    end
    super
    choose_pick_next
  end

  def pick(capt, player)
    unless capt.party == pick_next
      raise NotYourTurn, "It's not #{capt.login}'s turn."
    else
      raise PlayerNotJoined, "#{player.login} hasn't joined Game \##{self.id}." unless gm(player)
      if player.party == :staged
        gm(player).party = pick_next
        choose_pick_next
        save
      else
        raise AlreadyPicked, "#{player.login} has been picked."
      end
    end
  end

  def choose_pick_next
    case sentinel.size <=> scourge.size
    when 1
      :sentinel
    when 0
      [:sentinel, :scourge].sample
    when -1
      :scourge
    end
  end

  def picking_captain
    game_memberships.first(:party => pick_next).player
  end
end

class GameException < StandardError; end
class NotVouched < GameException; end
class Banned < GameException; end
class PlayerPlaying < GameException; end
class CaptainGameException < GameException; end
class NotYourTurn < CaptainGameException; end
class AlreadyPicked < CaptainGameException; end
class PlayerNotJoined < CaptainGameException; end
