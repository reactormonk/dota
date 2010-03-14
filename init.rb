#!/usr/bin/ruby --disable-gems
# encoding: utf-8

# default encoding setup
Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

# bundler
begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "bundler"
  Bundler.setup(:default, :development)
end
require 'dm-core' # bundler on heroku seems to have... issues.
Bundler.require(:default)

require "rango/stacks/controller"

Rango.environment = "test" if $0 =~ /baretest/
unless %w[test development stage production].include?(Rango.environment)
  abort "Unknown environment: #{Rango.environment}"
end

# we need to load dependencies before boot, so bootloaders will be called
Rango.logger.info("Loading dependencies for #{Rango.environment}")

Rango.boot

# load AppConfig
require_relative "load_config"

# register applications
require_relative "app/models.rb"
require_relative "app/controllers.rb"
require_relative "app/styles.rb"

# environment-specific settings
require_relative "environments"

# if you will run this script with -i argument, interactive session will begin
Rango.interactive if ARGV.delete("-i")

# so it can work as a runner
# ./init.rb: start webserver
if ARGV.length > 0 && $0.eql?(__FILE__)
  # config.ru
  if ARGV.last.split(".").last.eql?("ru")
    if Rango.development?
      load File.join(File.dirname(__FILE__), "bin", "shotgun")
    else
      load File.join(File.dirname(__FILE__), "bin", "rackup")
    end
  else
    load ARGV.shift
  end
end

# require rack stuff
require "rango/rack/middlewares/basic"
require_relative "config/router"
require_relative "config/warden"
