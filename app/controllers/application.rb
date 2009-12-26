require 'rango/mixins/rendering'
class Application < Merb::Controller
  include Rango::ExplicitRendering

  def scope
    super.tap do |scope|
      scope.extend ResourceHelper
      scope.instance_variable_set("@params", self.request.params)
      scope.extend Merb::Helpers 
      scope.extend Merb::AssetsMixin 
    end
  end

end

module ResourceHelper
  # Port from Merb::Controller
  def resource(*args)
    args << @params
    Merb::Router.resource(*args)
  end
end
