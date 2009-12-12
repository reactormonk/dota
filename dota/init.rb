# encoding: utf-8

require "rango/mixins/application"

module Dota
  extend Rango::ApplicationMixin
end

require_relative "models.rb"
require_relative "views.rb"
