# encoding: utf-8

# http://wiki.github.com/botanicus/rango/controllers

require "rango/helpers"
require "rango/controller"
require "rango/mixins/render"
require "rango/mixins/rendering"
require "rango/mixins/filters"
require "rango/mixins/message"

module DotA
  class Application < Rango::Controller
    include Rango::FiltersMixin
    include Rango::MessageMixin
    include Rango::RenderMixin
    include Rango::ExplicitRendering

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

  end

  class ShowCase < Application
    def index
      render "index.html"
    end
  end

end

require "rubyexts"

acquire_relative "controllers/*.rb"
