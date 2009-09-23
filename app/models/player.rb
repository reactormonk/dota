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
  has n, :game_memberships
  has n, :games, :through => :game_memberships

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

  def join(game)
    game.join(self)
  end

  def leave
    if is_playing?
      where_playing.leave(self)
      return true
    else
      return false
    end
  end

  def is_playing?
    !! where_playing
  end

  def where_playing
    games.first(:state => [:challenged, :running, :staged])
  end

  def party
    game_memberships.first(:game => where_playing).party
  end
end
