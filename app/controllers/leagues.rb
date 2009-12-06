class Leagues < Application

  def index
    @leagues = League.all
    display @leagues
  end

  def show
    @league = League.first(:name => Merb::Parse.unescape(params[:name]))
    display @league
  end
  
end
