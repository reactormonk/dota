class Players < Application
#   before :ensure_authenticated, :exclude => [:show, :index, :name]

  def index
    @players = Player.all
    render "players/index"
  end

  def show
    @player = Player.first(:name => params[:name])
    raise NotFound unless @player
    render "players/show"
  end

  def name
    if warden.authenticate(:password)
      flash.notice = "Logged in successfully."
    else
      flash.error = "You failed at name."
    end
    redirect("/")
  end

end
