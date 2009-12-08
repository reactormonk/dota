# encoding: utf-8
Dir.entries('dota').each {|file| require_relative file if file =~ /*\.rb/}
