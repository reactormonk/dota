class Players < Application
  #before :ensure_authenticated, :exclude => [:show, :index, :login, :login!]

  def index
    @players = Player.all
    render "players/index"
  end
  
  def show
    @player = Player.first(:login => Merb::Parse.unescape(params[:login]))
    puts @player
    raise NotFound unless @player
    @game = @player.where_playing
    render "players/show"
  end

  def login
    render "login"
  end
  
  def login!
    warden.authenticate(:password)
    redirect("/")
  end

end
