class MenuPart < Merb::PartController

  def index
     if @user = session.user
       if @user.playing?
         @game = @user.where_playing
       end
     end
    render
  end

end
