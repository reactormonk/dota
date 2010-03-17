class Players < Application
#   before :ensure_authenticated, :exclude => [:show, :index, :login]

  def index
    @players = Player.all
    render "players/index"
  end

  def show
    @player = Player.first(:login => params[:login])
    raise NotFound unless @player
    render "players/show"
  end

  def login
    if warden.authenticate(:password)
      flash.notice = "Logged in successfully."
    else
      flash.error = "You failed at login."
    end
    redirect("/")
  end

end
