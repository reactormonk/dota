class Players < Application

  def index
    @players = Player.all
    display @players
  end
  
  def show
    @player = Player.first(:login => Merb::Parse.unescape(params[:login]))
    raise NotFound unless @player
    display @player
  end

end
