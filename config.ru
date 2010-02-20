#\ -p 4000 -s thin
# encoding: utf-8

require "rango/rack/middlewares/basic"

# Load init.rb even if config.ru is just loaded 
# This comes handy in Passenger etc, but it's still
# useful to have config.ru as an executable, because
# it's easy to have default arguments for bin/rackup
require_relative "init.rb" unless $0.eql?(__FILE__)

# http://wiki.github.com/botanicus/rango/routers
Rango::Router.use(:usher)

# http://github.com/joshbuddy/usher
require_relative "config/router"

# Warden
require_relative "config/warden"

use Rack::Session::Cookie
use Warden::Manager do |manager|
  manager.default_strategies :dsde_cookie, :bot, :password
  manager.failure_app = proc { raise NotAuthenticated }
end
use Rango::Middlewares::Basic
run Rango::Router.app
