BareTest.new_component :rango_rack_test do
  require 'rack/test'

  module Rack::Test::Methods
    def app
      Rango::Router.app
    end
  end
  BareTest::Assertion::Context.send :include, Rack::Test::Methods
end
