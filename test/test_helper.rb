ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require_relative '../gem_server'

require 'minitest/autorun'
require 'rack/test'
require 'minitest/reporters'

MiniTest::Reporters.use!