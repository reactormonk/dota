class Players < Application
  before :ensure_authenticated, :exclude => [:show, :index, :login]

  def index
    @players = Player.all
  end

  def show
    @player = Player.first(:login => params[:login])
    raise NotFound unless @player
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
