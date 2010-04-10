class Player
  include CustomResource
  #
  # Properties
  #
  property :id,     Serial
  property :name,  String, :required => true, :unique => true
  property :qauth,  String
  property :foreign_id, Integer

  # 
  # Associations
  #
  has n, :league_memberships
  has n, :leagues, :through => :league_memberships
  has n, :game_memberships
  has n, :games, :through => :game_memberships

  #
  # Hooks
  #
  before :save, :generate_lm

  def generate_lm
    return true unless new?
    self.leagues |= League.all
  end

  #
  # Logic
  #

  def leave
    if (game = where_playing)
      game_memberships(game: game).destroy
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
    # TODO
  end

  def challenged
    games.first(:state => :challenged)
  end

  def challenged?
    !! challenged
  end

end
