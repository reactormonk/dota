# encoding: utf-8

# NOTE: we don't have to require spec, webrat,
# rack/test or whatever, it's bundler job to do it

# load test environment include dependencies
RANGO_ENV = "test"
require_relative "../init.rb"

require 'rango/utils'

# load config.ru
Rango::Utils.load_rackup

# webrat
Webrat.configure do |config|
  config.mode = :rack
end

require_relative 'spec_fixtures.rb'

# rspec
Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
  config.include Webrat::Matchers

  # automigrate database
  # TODO: with this setup it runs after custom block, so
  # if you create a record, it will be destroyed immediately
  #config.before(:each) do
  #  DataMapper.auto_migrate!
  #end
  DataMapper.auto_migrate!

  # for rack-test
  def app
    Rango::Router.app
  end
end
