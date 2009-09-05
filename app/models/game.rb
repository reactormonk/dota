class Game
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :start_time, DateTime, :default => lambda { |r,p| DateTime.now }
  property :end_time, DateTime
  property :mode, String
  property :result, Enum[:undecided, :sentinel, :scourge, :aborted], :default => :undecided, :nullable => false
  property :state, String
  
  #
  # Associations
  #
  belongs_to :league
  has n, :game_memberships
  has n, :players, :through => :game_memberships

end
