module Styles
  class League < CustomStyle
    style_for(::League)

    association :league_memberships, :players, :game_memberships, :games

    def prepare
    end

  end
end
