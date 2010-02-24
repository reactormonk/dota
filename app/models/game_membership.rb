class GameMembership
  include DataMapper::Resource

  #
  # Properties
  #
  property :id, Serial
  property :score, Float, :required => true
  property :party, Enum[:staged, :scourge, :sentinel], :required => true, :default => :staged
  property :captain, Boolean, :default => false
  property :vote, Enum[:none, :abort, :win, :fail], :default => :none

  # 
  # Associations
  #
  belongs_to :game
  belongs_to :player

  def league
    game.league
  end

  def league_membership
    player.league_memberships(:league => league).first
  end

  #
  # Validations
  #
  validates_present :league
  validates_with_method :game, :method => :may_pick?, :if => :picked, :message => "You may not pick."
  validates_with_method :player, :method => :may_be_picked, :if => :picked, :message => "is already picked."
  validates_with_method :player, :method => :not_playing?, :if => :new?, :message => "is playing already"
  validates_with_method :league, :method => :vouched?, :if => :new?, :message => "is not vouched."
  validates_with_method :league, :method => :not_banned?, :if => :new?, :message => "is banned."
  validates_with_method :league, :method => :captain?, :if => proc { |gm|
    gm.new? && gm.game.state == "challenged" && league.captain?(gm.player)
  }, :message => "is not a captain."

  #
  # Logic
  #

  # Should be set only if CaptainGame
  attr_accessor :picked

  def not_playing?
    !(player.playing? && player.where_playing != game)
  end

  def vouched?
    league.vouched?(player)
  end

  def not_banned?
    !league.banned?(player)
  end

  def captain?
    league.captain?(player)
  end

  before :destroy do
    !game.persistent?
  end

  def may_pick?
    picking_party = [nil, :sentinel, :scourge][game.sentinel.size <=> game.scourge.size]
    return false if game.send(:picking_party).size == 5
    if picking_party
      picking_party == party
    else
      true
    end
  end

  def may_be_picked?
    real_gm = self.class.get(id)
    real_gm.party == :staged
  end

  before :valid?, :fetch_score

  def fetch_score
    raise "No LeagueMembership found, probably :game association missing." unless league_membership
    self.score = league_membership.score
  end

  after :vote= do
    @note_check_votes = true
  end

  after :save, :check_votes

  def check_votes
    return true unless @note_check_votes
    game.check_votes
  end

  def clean_vote
    mapping = Hash.new {|h,k| h[k] = k}
    if party == :sentinel
      mapping.merge!({:win => :sentinel, :fail => :scourge})
    else
      mapping.merge!({:fail => :sentinel, :win => :scourge})
    end
    mapping[attribute_get(:vote)]
  end
end
