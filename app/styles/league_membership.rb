module Styles
  class LeagueMembership < CustomStyle
    style_for(::LeagueMembership)

    association :league, :player

    def prepare
    end

  end
end
