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
end
