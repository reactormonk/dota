module Styles
  class Game < CustomStyle
    style_for(::Game)

    def prepare
      self.send("prepare_for_#{normalize_state(@model.state)}")
    end

    def prepare_for_challenged
    end

    def prepare_for_staged
      if !@player
        "Erstelle zuerst einen Player."
      elsif @player.is_playing?
        @playing_message = "Du spielst schon in Game ##{@player.where_playing.id}."
      elsif @player.banned?(@model.league)
        @league_message = "Du bist in #{@model.league.name} gebannt."
      elsif !@player.vouched?(@model.league)
        @league_message = "Lass dich erstmal in #{@model.league.name} vouchen."
      end
    end

    def prepare_for_running
    end

    def prepare_for_finished
    end

    def default
      @template = "games/presenters/#{normalize_state(@model.state)}"
      self
    end

    def widget
      @template = "games/presenters/widget/#{normalize_state(@model.state)}"
      self
    end

    private
    def normalize_state(state)
      states = Hash.new {|h,k| k }
      states.merge({
        "scourge_won" => "finished",
        "sentinel_won" => "finished",
      })
      states[state]
    end

  end
end
