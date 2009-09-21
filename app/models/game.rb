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
    return false unless allowed_to_join?(player)
    players << player
    save
  end

  def leave(player)
    gm(player).destroy
    destroy if game_memberships.size == 0
  end

  def allowed_to_join?(player)
    player.is_vouched?(league) &&
    ! player.is_banned?(league) &&
    ! player.is_playing?
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

  def distribute_captains
    # check allowed_to_join?
    #return unless captain_memberships.all(:party => :staged).size == 2
    party1, party2 = [:sentinel, :scourge].shuffle
    party_set(captains.first,party1)
    party_set(captains.last,party2)
  end

  def leave(player)
    if captains.include? player
      destroy
      save
      return true
    end
    super
  end

  def pick(capt, player)
    unless capt.party == pick_next
      # error here
    else
      unless player.party == :staged
        player.party = pick_next
        choose_pick_next
      else
        # error here
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
end
