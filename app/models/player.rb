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

  def join_as_captain(game)
    game.join_as_captain(self)
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

  def challenge(league, player=nil)
    case
    when captain_game = challenged
      if games.game_memberships(:league => league, :game => captain_game).party == :scourge
        captain_game.accept_challenge(self)
      else
        raise PlayerPlaying, "You've challenged someone."
      end
    when player
      captain_game = CaptainGame.new(:league => league)
      captain_game.challenges(self, player)
    else
      # Accept a challenge or make a new one
      if captain_game = CaptainGame.first(:state => :challenged, :league => league)
        captain_game.accept_challenge(self)
      else
        captain_game = CaptainGame.create(:league => league, :captains => [self])
      end
    end
    captain_game
  end

  def challenged
    games.first(:state => :challenged)
  end

  def challenged?
    !! challenged
  end
end
