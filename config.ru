# frozen_string_literal: true

require 'rack/unreloader'

require_relative './main'

Unreloader = Rack::Unreloader.new(
  handle_reload_errors: true,
  subclasses: %w[Sinatra::Base]
) { App }

Unreloader.require './models/memo.rb'
Unreloader.require './route/api.rb'
Unreloader.require './main.rb'
Unreloader.require './helpers/init.rb'

run Unreloader
