class LeagueMembership
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :score, Float, :default => 1000.0
  property :vouched, Boolean, :default => false

  # 
  # Associations
  #
  belongs_to :player
  belongs_to :league

end
