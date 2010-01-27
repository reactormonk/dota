class Player
  include DataMapper::Resource
  #
  # Properties
  #
  property :id,     Serial
  property :login,  String, :required => true, :unique => true
  property :qauth,  String
  property :admin,  Boolean, :default => false

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

  def banned?(league)
    league.banned?(self)
  end

  def vouch(league)
    league.vouch(self)
  end

  def vouched?(league)
    league.vouched?(self)
  end

  def bans(league)
    league.bans(self)
  end

  def join(game)
    game.join(self)
  end

  def join_as_captain(game)
    game.join_as_captain(self)
  end

  def leave
    if playing?
      !! where_playing.leave(self)
    else
      return false
    end
  end

  def playing?
    !! where_playing
  end

  def where_playing
    games.first(:state => [:challenged, :running, :staged])
  end

  def party
    game_memberships.first(:game => where_playing).party
  end

  def accept_challenge
    captain_game = challenged 
    unless captain_game && game_memberships.first(:game => captain_game).party == :scourge
      raise NotChallenged, "You're not challenged."
    end
    captain_game.accept_challenge(self)
  end

  # I'm not even sure if you should use this method... it's just for spec backwards compability ;-)
  def challenge(league, player=nil)
    if captain_game = challenged
      raise PlayerPlaying, "You're playing in #{captain_game}."
    elsif player
      captain_game = league.direct_challenge(self, player)
    else
      captain_game = league.anonymous_challenge(self)
    end
    captain_game
  end

  def challenged
    games.first(:state => :challenged)
  end

  def challenged?
    !! challenged
  end
  
  def vote(chosen)
    where_playing.vote(self, chosen)
  end

  def score(league)
    league_memberships.first(:league => league).score
  end

  def give_permission(permission, league)
    league.give_permission(permission, self)
  end

  def take_permission(permission, league)
    league.take_permission(permission, self)
  end

  #
  # warden
  #
  property :encrypted_password, BCryptHash, :required => true
  
  validates_is_confirmed :password

  attr_accessor :password, :password_confirmation
  
  def password=(pass)
    @password = pass
    self.encrypted_password = pass
  end
end
