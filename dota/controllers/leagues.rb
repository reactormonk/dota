module DotA
class Leagues < Application
  before :ensure_authenticated, :exclude => [:show, :index]

  def index
    @leagues = League.all
    display @leagues
  end

  def show
    @league = League.first(:name => Merb::Parse.unescape(params[:name]))
    display @league
  end
  
end
end
