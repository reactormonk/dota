# encoding: utf-8

# http://wiki.github.com/botanicus/rango/controllers

require "rango/helpers"
require "rango/controller"
require "rango/mixins/filters"
require "rango/mixins/rendering"
require "rango/mixins/message"
require "rango/mixins/action_args"
require "rango/router/adapters/crudtree"

class Application < Rango::Controller
  include Rango::FiltersMixin
  include Rango::MessageMixin
  include Rango::ImplicitRendering
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
end

class ShowCase < Application
  def index
    render "index.html"
  end
end


%w(exceptions.rb games.rb leagues.rb players.rb).each {|file| require_relative("controllers/" + file)}
