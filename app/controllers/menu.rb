class Menu < Application
  def menu
    @personal_menu = user ? "./personal" : "./non_personal"
    render "menu/menu"
  end
end
