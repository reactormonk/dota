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

  def challenge(league, player=nil)
    if captain_game = challenged
      raise PlayerPlaying, "You're playing in #{captain_game}."
    elsif player
      captain_game = CaptainGame.create(:league => league)
      captain_game.challenges(self, player)
      captain_game.save
    else
      # Accept a challenge or make a new one
      if captain_game = CaptainGame.first(:state => "challenged", :league => league)
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
  
  def vote(chosen)
    game = where_playing
    raise GameNotRunning unless game.state == "running"
    gm = game_memberships.first(:player => self)
    gm.vote = chosen
    gm.save
    game.check_votes
  end

  def score(league)
    league_memberships.first(:league => league).score
  end
end
