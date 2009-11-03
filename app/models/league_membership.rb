class LeagueMembership
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :score, Float, :nullable => false, :default => 1000.0
  property :vouched, Boolean, :default => false
  property :admin, Boolean, :default => false

  # 
  # Associations
  #
  belongs_to :player
  belongs_to :league
  has n, :bans, :model => "LeagueBan"

end
