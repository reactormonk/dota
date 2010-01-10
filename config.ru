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

use Rango::Middlewares::Basic
run Rango::Router.app
