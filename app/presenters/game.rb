module Presenters
  class Game
    include Presenter
    def initialize(game)
      @game = game
      generate_messages
      self
    end

    def generate_messages
    end

    def default
      render "games/presenters/#{template_for_state(@game.state)}"
    end

    def widget
      render "games/presenters/widget/#{template_for_state(@game.state)}"
    end

    private
    def template_for_state(state)
      templates = Hash.new {|h,k| k }
      templates.merge({
        "scourge_won" => "finished",
        "sentinel_won" => "finished",
      })
      templates[state]
    end

  end
end
