#!/usr/bin/env nake
# encoding: utf-8

require_relative "gems/environment.rb"
require 'ruby-debug'

# Boot environment
# This task isn't useful as is, but a lot of Rango tasks expect this
# will exist and take an optional argument with name of environment
Task.new(:environment) do |task|
  task.hidden = true
  task.define do |environment = nil, options|
    RACK_ENV = environment || ENV["RACK_ENV"] || "development"
    require_relative "init.rb"
  end
end

#load "pupu/tasks/pupu.nake"
load "rango/tasks/spec.nake"
load "rango/orm/tasks/datamapper.nake"

begin
  load "git-deployer.nake"
  Task["deployer:setup"].config[:servers] = {
    server1: {
      user: "TODO",
      host: "TODO",
      repo: "/var/sources/blog.git",
      path: "/var/www/blog"
    }
  }
rescue LoadError
  warn "You have to install git-deployer gem if you want to deploy to remote servers!"
end

