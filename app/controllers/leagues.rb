class Leagues < Application
  before :ensure_authenticated, :exclude => [:show, :index]

  def index
    render "leagues/index", leagues: League.all
  end

  def show
    render "leagues/show", league: League.first(:name => Merb::Parse.unescape(params[:name]))
  end
  
end
