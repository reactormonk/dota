module Dota
class LeagueBan
  include DataMapper::Resource
  
  property :id, Serial
  property :until, DateTime
  property :reason, String

  #
  # Associations
  #
  belongs_to :league_membership
  has 1, :league, :through => :league_membership
  has 1, :player, :through => :league_membership

end
end
