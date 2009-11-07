class Games < Application

  def index
    @games = Game.all
    display @games
  end

  def show
    @game = Game.first(:id => params[:id])
    display @game
  end
  
end
