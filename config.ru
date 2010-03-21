#\ -p 4000 -s thin
# encoding: utf-8

# Load init.rb even if config.ru is just loaded 
# This comes handy in Passenger etc, but it's still
# useful to have config.ru as an executable, because
# it's easy to have default arguments for bin/rackup
require_relative "init.rb" unless $0.eql?(__FILE__)

use Rango::Middlewares::Basic
use Rack::R18n
use Rack::Session::Cookie
use Rack::Flash, :accessorize => [:notice, :error]
use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.serialize_into_session {|player| player.id}
  manager.serialize_from_session {|id| Player.get(id)}
end
run Rango::Router.app
