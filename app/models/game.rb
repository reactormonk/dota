require 'state_machine'

class Game
  include DataMapper::Resource

  #
  # Properties
  #
  property :id, Serial
  property :start_time, DateTime
  property :end_time, DateTime
  property :mode, String, :default => Rango::AppConfig[:game_mode], :required => true
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
    state :running, :scourge, :sentinel, :aborted do
      validates_present :mode
      validates_size :sentinel, :size => 5
      validates_size :scourge, :size => 5
    end
    state :aborted, :scourge, :sentinel do
      validates_with_method :state, :valid_votes
    end

    before_transition :running => any - :aborted, :do => :process_score
    before_transition :on => :start, :do => [:push_start_time, :drop_staged_players]

    event :start do
      transition :staged => :running
    end
    event :vote_scourge do
      transition :running => :scourge
    end
    event :vote_sentinel do
      transition :running => :sentinel
    end
    event :vote_abort do
      transition :running => :aborted
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

  def valid_votes
    if (result = count_votes) == :abort
      state == "aborted"
    else
      result.to_s == state
    end
  end

  #
  # Logic
  #
  default_scope(:default).update(:order => [:start_time.desc])

  def persistent?
    ["sentinel", "scourge", "aborted", "running"].include? state
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
    result = count_votes
    send("vote_#{result}") if result
  end

  def count_votes
#     game_memberships.reload
    result = game_memberships.reduce(Hash.new(0)) do |hsh, gm|
      hsh[gm.vote] += 1 unless gm.vote == :none ; hsh
    end.find do |vote, number|
      number >= Rango::AppConfig[:votes_needed]
    end
    result && result.first
  end
end
