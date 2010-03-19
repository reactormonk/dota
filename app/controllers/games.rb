class Games < Application
  before :ensure_authenticated, :exclude => [:show, :index, :staged, :running, :finished]

  def index
    @games = style Game.all
    render 'games/index'
  end

  def show
    @game = style Game.first(:id => params[:id])
    render 'games/show'
  end

  def staged
    state(:staged)
  end

  def running
    state(:running)
  end

  def finished
    state([:aborted, :sentinel_won, :scourge_won])
  end

  TYPES = {
    "random" => RandomGame,
    "captain" => CaptainGame
  }

  private
  def state(states)
    @games = style Game.all(:state => states)
    render "games/index"
  end

end
