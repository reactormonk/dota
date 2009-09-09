class Player
  include DataMapper::Resource
  #
  # Properties
  #
  property :id,     Serial
  property :login,  String, :nullable => false, :unique => true
  property :qauth,  String, :nullable => false

  # 
  # Associations
  #
  has n, :league_memberships
  has n, :leagues, :through => :league_memberships

  #
  # Logic
  #
  def ban(league, *args)
    league.ban(self, *args)
  end

  def is_banned?(league)
    league.is_banned?(self)
  end

  def vouch(league)
    league.vouch(self)
  end

  def is_vouched?(league)
    league.is_vouched?(self)
  end

  def bans(league)
    league.bans(self)
  end

end
