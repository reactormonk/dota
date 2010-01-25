# encoding: utf-8

# http://wiki.github.com/botanicus/rango/environments-support
require "rango/environments"
require 'ruby-debug'

# database connection
case Rango.environment
when "production", "staging"
  raise "Not ready to use yet"
when "development"
  DataMapper::Logger.new(STDOUT, :debug)
  DataMapper.setup(:default, "sqlite3:db/#{Rango.environment}.db")
when "test", "spec", "cucumber"
  DataMapper.setup(:default, "sqlite3::memory:")
end

if Rango.development?
  Rango.logger = SimpleLogger::Logger.new(STDOUT)
  Rango.logger.auto_flush = true
else
  Rango.logger = SimpleLogger::Plain.new("log/#{Rango.environment}.log")
  Rango.logger.auto_flush = false
end

# write log at exit
at_exit { Rango.logger.close }
# encoding: utf-8

require 'yaml'

config_file = File.join(Rango.root, "config", "application.yml")

if File.exists?(config_file)
  config = YAML.load(File.read(config_file))[Rango.environment]

  Rango::AppConfig = {}

  config.keys.each do |key|
    Rango::AppConfig[key.to_sym] = config[key]
  end
end
