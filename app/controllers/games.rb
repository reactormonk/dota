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
    # TODO we got better things now
    user = session.user
    type = TYPES[params[:type].to_s.downcase.chomp("game")]
    raise ArgumentError unless league = League.first(params[:league])
    # Suggestions are welcome
    case type.object_id
    when RandomGame.object_id
      game = RandomGame.new(:league => league)
      game.join user
    when CaptainGame.object_id
      if player = Player.first(params[:challenged])
        unless player.captain?
          game = user.challenge(league, player)
        else
          message[:error] = "The challenged player is no Captain."
        end
      else
        game = user.challenge(league)
      end
    else
      raise ArgumentError
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
