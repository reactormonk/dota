class GameMembership
  include CustomResource

  #
  # Properties
  #
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
  validates_with_method :game, :method => :may_pick?, :if => :picked, :message => proc {|r| t.game_membership.may_not_pick}
  validates_with_method :player, :method => :may_be_picked, :if => :picked, :message => proc {|r| t.game_membership.already_picked(r.player.name)}
  validates_with_method :player, :method => :not_playing?, :if => :new?, :message => proc {|r| t.game_membership.playing_already(r.player.where_playing.id)}
  validates_with_method :league, :method => :vouched?, :if => :new?, :message => proc {|r| t.game_membership.not_vouched(r.league)}
  validates_with_method :league, :method => :not_banned?, :if => :new?, :message => proc {|r| t.game_membership.banned(r.league)}
  validates_with_method :league, :method => :captain?, :if => proc { |gm|
    gm.new? && gm.game.state == "challenged" && league.captain?(gm.player)
  }, :message => proc {|r| t.game_membership.not_captain(r.league)}

  #
  # Logic
  #

  # Should be set only if CaptainGame
  attr_accessor :picked

  #
  # Accessors
  #

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

  CLEAN_VOTE_MAPPING = {
    sentinel: {
      abort: :abort,
      win:  :sentinel,
      fail: :scourge
    },
    scourge: {
      abort: :abort,
      win:  :scourge,
      fail: :sentinel
    }
  }

  def clean_vote
    CLEAN_VOTE_MAPPING[party][attribute_get(:vote)]
  end

  #
  # Callbacks
  #

  before :destroy do
    throw :halt if game.persistent?
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
    raise "No Player found." unless player
    raise "No LeagueMembership found, probably :game association missing." unless league_membership
    self.score = league_membership.score
  end

  after :vote= do
    @note_check_votes = true
  end

  after :save, :check_votes

  def check_votes
    return unless @note_check_votes
    game.check_votes
  end

  before :save, :randomize_party

  def randomize_party
    return unless game.respond_to? :randomize_party
    self.party = game.randomize_party
  end

end
