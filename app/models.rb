require 'dm-core'
require 'dm-types'
require 'dm-validations'
require_relative "presenters.rb"

module ModelBasics
  include Presenters::Mixin
end
%w(game.rb game_membership.rb league.rb league_ban.rb league_membership.rb player.rb score_processing.rb).each {|file| require_relative("models/" + file)}
