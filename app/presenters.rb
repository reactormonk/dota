require "rango/mixins/rendering"

module Presenters
  module Mixin
    def present(type=:default)
      Presenters.present(self, type)
    end
  end

  def present(model, type)
    const_get(model.class.to_s).new(model).send(type)
  end

  module_function :present
end

module Presenter
  include Rango::ImplicitRendering
  include Rango::Helpers
end

%w(game).each {|file| require_relative("presenters/" + file)}
