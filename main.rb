# frozen_string_literal: true

require 'sinatra'

set :environment, :production

get '/' do
  erb :index
end
