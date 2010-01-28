class GameMembership
  include ModelBasics
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

end
