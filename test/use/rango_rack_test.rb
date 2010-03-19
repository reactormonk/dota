BareTest.new_component :rango_rack_test do
  require 'rack/test'
  require 'rango/utils'

  module Rack::Test::Methods
    def app
      Rango::Utils.load_rackup
    end
  end
  BareTest::Assertion::Context.send :include, Rack::Test::Methods
end
