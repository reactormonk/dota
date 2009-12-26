class Games < Application
  before :ensure_authenticated, :exclude => [:show, :index, :staged, :running, :finished]

  def index
    render 'games/index', games: Game.all
  end

  def show
    game = Game.first(:id => params[:id])
    render "games/show/#{template_for_state(game.state)}", game: game
  end

  def join
    game = Game.first(:id => params[:id])
    begin
      game.join(session.user)
    rescue PlayerPlaying => e
      message[:error] = "Du spielt schon in Game ##{e.game}"
    rescue NotVouched => e
      message[:error] = "Lass ich erstmal in #{e.league} vouchen"
    else
      message[:notice] = "Alles paletti, du bist in Game ##{game.id}."
    end
    redirect resource(game), :message => message
  end

  def leave
    game = Game.first(:id => params[:id])
    begin
      game.leave(session.user)
    rescue GameRunning => e
      message[:error] = "Du kannst Game ##{e.game} nicht verlassen, es befindet sich im Status #{e.game.state}."
    end
    redirect resource(game), :message => "Du hast #{game} verlassen."
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

  def new
  end

  def create
  end

  TYPES = {
    "random" => RandomGame,
    "captain" => CaptainGame
  }

  private
  def state(states)
    @games = Game.all(:state => states)
    display @games, :template => "games/show"
  end

  def template_for_state(state)
    templates = Hash.new {|h,k| k }
    templates.merge({
      "scourge_won" => "finished",
      "sentinel_won" => "finished",
    })
    templates[state]
  end
  
end
