module Styles
  class Game < CustomStyle
    style_for(::Game)

    def prepare
      @template_path = compile_template_path << "/" << normalized_state
    end

    private
    STATE_MAPPING = Hash.new {|h,k| k }
    STATE_MAPPING.merge!({
      "scourge_won" => "finished",
      "sentinel_won" => "finished",
    })
    def normalized_state
      STATE_MAPPING[state]
    end

  end
end
