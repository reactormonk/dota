class Players < Application
#   before :ensure_authenticated, :exclude => [:show, :index, :name]

  def index
    @players = style Player.all
    render "players/index"
  end

  def show
    @player = style Player.first(:name => params[:name])
    raise NotFound unless @player
    render "players/show"
  end

end
