# frozen_string_literal: true

require 'rack/unreloader'

Unreloader = Rack::Unreloader.new(
  handle_reload_errors: true,
  subclasses: %w[Sinatra::Base]
) { App }
Unreloader.require './main.rb'

run Unreloader
