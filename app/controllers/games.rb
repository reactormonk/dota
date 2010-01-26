class Games < Application
  before :ensure_authenticated, :exclude => [:show, :index, :staged, :running, :finished]

  def index
    @games = Game.all
    render 'games/index'
  end

  def show
    @game = Game.first(:id => params[:id])
    render "games/show/#{template_for_state(@game.state)}"
  end

  def join
    @game = Game.first(:id => params[:id])
    begin
      @game.join(session.user)
    rescue PlayerPlaying => e
      message[:error] = "Du spielt schon in Game ##{e.game}"
    rescue NotVouched => e
      message[:error] = "Lass ich erstmal in #{e.league} vouchen"
    else
      message[:notice] = "Alles paletti, du bist in Game ##{@game.id}."
    end
    redirect resource(@game), :message => message
  end

  def leave
    @game = Game.first(:id => params[:id])
    begin
      @game.leave(session.user)
    rescue GameRunning => e
      message[:error] = "Du kannst Game ##{e.game} nicht verlassen, es befindet sich im Status #{e.game.state}."
    end
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

  def new
    @user = session.user
    @leagues = @user.league_memberships(:vouched => true).leagues
    @types = TYPES.values.map {|value| value.to_s.chomp("Game")}
    @captains = LeagueMembership.all(:captain => true)
  end

  def create
    user = session.user # TODO warden
    type = TYPES[type.to_s.downcase.chomp("game")]
    raise(ArgumentError, "No League found.") unless league = League.first(:name => params[:league])
    # Suggestions are welcome
    case type.object_id
    when RandomGame.object_id
      game = RandomGame.new(:league => league)
      game.join user
    when CaptainGame.object_id
      if challenged = Player.first(:id => params[:challenged]) # can we do this better?
        game = league.direct_challenge(user, challenged)
      else
        game = league.anonymous_challenge(user)
      end
    else
      raise ArgumentError, "Invalid game type."
    end
    redirect resource(game)
  end

  TYPES = {
    "random" => RandomGame,
    "captain" => CaptainGame
  }

  private
  def state(states)
    @games = Game.all(:state => states)
    render "games/index"
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
