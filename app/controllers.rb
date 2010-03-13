# encoding: utf-8

# http://wiki.github.com/botanicus/rango/controllers

require "rango/controller"
require "rango/mixins/filters"
require "rango/router/adapters/crudtree"
require "styler/mixins/rango"

module Rango::Helpers
  def flash
    env['x-rack.flash']
  end
end

class Application < Rango::Controller
  include Rango::FiltersMixin
  include Styler::RangoMixin
  include Rango::Helpers

  # http://wiki.github.com/botanicus/rango/errors-handling
  def render_http_error(exception)
    if self.respond_to?(exception.to_snakecase)
      self.send(exception.to_snakecase, exception)
    else
      begin
        render "errors/#{exception.status}.html"
      rescue TemplateNotFound
        render "errors/500.html"
      end
    end
  end

  def warden
    env['warden']
  end

  def player
    warden.user(:player)
  end

end

class ShowCase < Application
  def index
    render "index.html"
  end
end


%w(exceptions games leagues players menu).each {|file| require_relative("controllers/" + file)}
