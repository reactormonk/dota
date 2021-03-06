require_relative "../init.rb"
Bundler.require(:test)
require 'factory_girl'
require_relative "helper/fixtures/fixtures"
require_relative "helper/fixtures/pick"
require_relative "use/datamapper"
require_relative "use/rango_rack_test"
require_relative "use/warden"

BareTest do
  require_baretest "0.4.0" # minimum baretest version to run these tests
  require_ruby     "1.9.1" # minimum ruby version to run these tests
  use              :support # Use :support in all suites
  use              :datamapper
end

R18n.set(R18n::I18n.new("en", "i18n"))
