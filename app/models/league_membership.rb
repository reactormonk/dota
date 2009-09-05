class LeagueMembership
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial

  # 
  # Associations
  #
  belongs_to :player
  belongs_to :league

end
