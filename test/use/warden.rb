BareTest.new_component :warden do
  require 'warden'

  teardown do
    Warden.test_reset!
  end

  BareTest::Assertion::Context.send :include, Warden::Test::WardenHelpers
end
