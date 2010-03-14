class Menu < Application
  def global_menu
    render "menu/global"
  end

  def personal_menu
    if player
      render "menu/personal"
    else
      render "menu/non_personal"
    end
  end
end