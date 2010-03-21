require 'dm-core'
require 'dm-types'
require 'dm-validations'

module CustomResource
  module ClassMethods
  end

  module InstanceMethods
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, DataMapper::Resource
    receiver.send :include, InstanceMethods
    receiver.send :include, Rack::R18n::Helpers
    receiver.property :id,  DataMapper::Types::Serial
  end
end

%w(game.rb random_game.rb captain_game.rb game_membership.rb league.rb decret.rb league_membership.rb player.rb score_processing.rb).each {|file| require_relative("models/" + file)}
