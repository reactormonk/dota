class Games < Application
  before :ensure_authenticated, :exclude => [:show, :index, :staged, :running, :finished]

  def index
    @games = Game.all
    display @games
  end

  def show
    @game = Game.first(:id => params[:id])
    display @game
  end

  def join
    @game = Game.first(:id => params[:id])
    begin
      @game.join(session.user)
    rescue PlayerPlaying
      message[:error] = "Du spielt schon in Game ##{session.user.where_playing.id}"
    rescue NotVouched
      message[:error] = "Lass ich erstmal in #{@game.league} vouchen"
    else
      message[:notice] = "Alles paletti, du bist in Game ##{@game.id}."
    end
    redirect resource(@game), :message => message
  end

  def leave
    @game = Game.first(:id => params[:id])
    @game.leave(session.user)
    redirect resource(@game), :message => "Du hast #{@game} verlassen."
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

  private
  def state(states)
    @games = Game.all(:state => states)
    display @games, :template => "games/show"
  end
  
end
