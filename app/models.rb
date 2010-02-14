require 'dm-core'
require 'dm-types'
require 'dm-validations'

%w(game.rb game_membership.rb league.rb league_ban.rb league_membership.rb player.rb score_processing.rb).each {|file| require_relative("models/" + file)}
