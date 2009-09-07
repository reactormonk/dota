class LeagueMembership
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :score, Float, :default => 1000.0

  # 
  # Associations
  #
  belongs_to :player
  belongs_to :league

end
