class Players < Application
  before :ensure_authenticated, :exclude => [:show, :index]

  def index
    render "players/index", players: Player.all
  end
  
  def show
    player = Player.first(:login => Merb::Parse.unescape(params[:login]))
    puts player
    raise NotFound unless player
    game = player.where_playing
    render "players/show", player: player, game: game
  end

end
