# Go to http://wiki.merbivore.com/pages/init-rb
 
use_orm :datamapper
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = '9024d0a71bc8c74de26f8336918137d35685b15a'  # required for cookie session store
  c[:session_id_key] = '_dota_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
  require 'logger'
  Rango.logger = Logger.new(STDOUT)
end
 
Merb::BootLoader.after_app_loads do
  require 'app_config'
  AppConfig.load
  require 'compat'
end
