class GameMembership
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :score, Float, :nullable => false
  property :party, Enum[:scourge, :sentinel], :nullable => false

  # 
  # Associations
  #
  belongs_to :game
  belongs_to :league, :through => :game
  belongs_to :player

end
