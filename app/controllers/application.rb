require 'rango/mixins/rendering'
class Application < Merb::Controller
  include Rango::ImplicitRendering

  def warden
    request.env['warden']
  end
end
