require "styler"

%w(game).each {|file| require_relative("styles/" + file)}
