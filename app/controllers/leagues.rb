class Leagues < Application
  #before :ensure_authenticated, :exclude => [:show, :index]

  def index
    @leagues = style League.all
    render "leagues/index"
  end

  def show
    @league = style League.first(:name => params[:name])
    render "leagues/show"
  end
end
