# encoding: utf-8

# http://wiki.github.com/botanicus/rango/controllers

require "rango/controller"
require "rango/mixins/render"
require "rango/mixins/filters"
require "rango/mixins/message"

module Dota
  class Application < Rango::Controller
    include Rango::FiltersMixin
    include Rango::MessageMixin
    include Rango::RenderMixin
  end

  class ShowCase < Application
    def index
      render "index.html"
    end
  end

end

require "rubyexts"

acquire_relative "controllers/*.rb"
