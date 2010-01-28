class LeagueMembership
  include ModelBasics
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :score, Float, :required => true, :default => 1000.0
  property :admin, Boolean, :default => false
  property :voucher, Boolean, :default => false
  property :captain, Boolean, :default => false
  property :vouched, Boolean, :default => false

  # 
  # Associations
  #
  belongs_to :player
  belongs_to :league
  has n, :bans, :model => "LeagueBan"

  def banned?
    !! bans.first(:until.gt => Time.now)
  end

end
