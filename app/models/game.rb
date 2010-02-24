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
  property :state, String
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
    state :running, :scourge_won, :sentinel_won, :aborted do
      validates_present :mode
      validates_size :sentinel, :size => 5
      validates_size :scourge, :size => 5
    end
    state :aborted, :scourge_won, :sentinel_won do
      validates_with_method :state, :valid_votes
    end

    before_transition :running => any - :aborted, :do => :process_score
    before_transition :on => :start, :do => [:push_start_time, :drop_staged_players]

    event :start do
      transition :staged => :running
    end
    event :scourge_wins do
      transition :running => :scourge_won
    end
    event :sentinel_wins do
      transition :running => :sentinel_won
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
    game_memberships(:party => :staged).destroy
  end

  #
  # Validations
  #

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
