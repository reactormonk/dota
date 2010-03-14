module Styles
  class Player < CustomStyle
    style_for(::Player)

    association :league_memberships, :leagues, :game_memberships, :games, :where_playing

    def prepare
    end

  end
end
