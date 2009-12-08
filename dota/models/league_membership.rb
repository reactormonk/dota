require 'dm-types'
class LeagueMembership
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :score, Float, :required => true, :default => 1000.0
  property :permissions, Flag[:vouched, :voucher, :captain, :admin]

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
