require 'rango/mixins/rendering'
class Application < Merb::Controller
  include Rango::ImplicitRendering
end
