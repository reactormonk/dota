require "rubygems"
require 'ruby-debug'

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "spec" # Satisfies Autotest and anyone else not using the Rake tasks

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you

require 'dm-sweatshop'
require File.join(File.dirname(__FILE__), 'spec_fixtures')

Spec::Runner.configure do |config|
  # for rack-test
  def app
    Rango::Router.app
  end
end
