class GameMembership
  include DataMapper::Resource

  #
  # Properties
  #
  property :id, Serial
  property :score, Float, :required => true, :default => proc {|r,p| LeagueMembership.first(:player => r.player, :league => r.game.league).score}
  property :party, Enum[:staged, :scourge, :sentinel], :required => true, :default => :staged
  property :captain, Boolean, :default => false
  property :vote, Enum[:none, :abort, :scourge_wins, :sentinel_wins], :default => :none

  # 
  # Associations
  #
  belongs_to :game
  has 1, :league, :through => :game
  belongs_to :player

  #
  # Validations
  #
  validates_with_method :game, :method => :may_pick?, :if => :picked, :message => "You may not pick."
  validates_with_method :player, :method => :may_be_picked, :if => :picked, :message => "is already picked."
  validates_with_method :player, :method => :playing?, :if => :new?, :message => "is playing already"
  validates_with_method :league, :method => :vouched?, :if => :new?, :message => "is not vouched."
  validates_with_method :league, :method => :banned?, :if => :new?, :message => "is banned."
  validates_with_method :league, :method => :captain?, :if => proc { |gm|
    gm.new? && gm.game.state == "challenged" && league.captain?(gm.player)
  }, :message => "is not a captain."

  #
  # Logic
  #

  # Should be set only if CaptainGame
  attr_accessor :picked

  def playing?
    player.playing?
  end

  def vouched?
    league.vouched?(player)
  end

  def banned?
    !league.banned?(player)
  end

  def captain?
    league.captain?(player)
  end

  def before_destroy
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
end
