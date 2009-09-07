class GameMembership
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :score, Float, :nullable => false, :default => proc {|r,p| LeagueMembership.first(:player => r.player, :league => r.league).score}
  property :party, Enum[:staged, :scourge, :sentinel], :nullable => false, :default => :staged

  # 
  # Associations
  #
  belongs_to :game
  has 1, :league, :through => :game
  belongs_to :player

end
