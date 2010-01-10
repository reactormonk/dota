class Leagues < Application
  #before :ensure_authenticated, :exclude => [:show, :index]

  def index
    @leagues = League.all
    render "leagues/index"
  end

  def show
    @league = League.first(:name => params[:name])
    render "leagues/show"
  end

  def new_random_game
    league = League.first(params[:name])
    player = session.user
    game = league.new_random_game(player)
    redirect resource(game)
  end
end
