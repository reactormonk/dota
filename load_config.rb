require 'yaml'

config_file = File.join(Rango.root, "config", "application.yml")

if File.exists?(config_file)
  config = YAML.load(File.read(config_file))[Rango.environment]

  Rango::AppConfig = {}

  config.keys.each do |key|
    Rango::AppConfig[key.to_sym] = config[key]
  end
end
