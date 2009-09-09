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
      when :staged, :running then :undecided
      when :scourge_won then :scourge
      when :sentinel_won then :sentinel
      when :aborted then :aborted
    end
  end

  def join(player)
    players << player
    save
  end

  def leave(player)
    game_memberships.first(:player => player).destroy
  end

end
