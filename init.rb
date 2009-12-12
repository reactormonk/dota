#!ruby --disable-gems
# encoding: utf-8

# This file should set Rango environment
# You can run your scripts with ./init.rb my-script.rb
# See http://wiki.github.com/botanicus/rango/rango-boot-process

# bundler
begin
  require_relative "gems/environment.rb"
rescue LoadError => exception
  abort "LoadError during loading gems/environment: #{exception.message}\nRun gem bundle to fix it."
end

# settings
require_relative "settings"
require_relative "settings_local"

require "rango"
require "rango/helpers"
require "rango/environments"

# http://wiki.github.com/botanicus/rango/environments-support
require "rango/environments"

environment = (ENV["RANGO_ENV"] || (RANGO_ENV if defined?(RANGO_ENV)) || "development").to_s
RACK_ENV = environment
unless %w[test development stage production].include?(environment)
  abort "Unknown environment: #{environment}"
end

# we need to load dependencies before boot, so bootloaders will be called
Rango.logger.info("Loading dependencies for #{environment}")
Bundler.require_env(environment)

Rango.boot(environment: environment)

# register applications
require_relative "dota/init.rb"

# database connection
DataMapper.setup(:default, "sqlite3:#{Rango.environment}.db")

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
