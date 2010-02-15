module Styles
  class Game
    include Styler::Style
    style_for(::Game)

    delegate :login, :party, :where_playing, :leagues

    def prepare
    end

  end
end
