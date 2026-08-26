# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'time'
require 'securerandom'

require_relative 'route/api'
require_relative 'models/memo'
require_relative 'helpers/validate'
# set :show_exceptions, false

class App < Sinatra::Base
  set :method_override, true
  set :memo_manager, MemoManager.new

  use ApiRoute, settings.memo_manager

  helpers do
    def memo_manager
      settings.memo_manager
    end
  end

  before '/memos/:id/*' do
    memo_id = @params[:id]
    target_memo = memo_manager.find(memo_id)
    @error_message = 'memo not found'
    @memos = memo_manager.memos
    halt 404, erb(:'index.html') unless target_memo
  end

  get '/' do
    @memos = memo_manager.memos
    erb :'index.html'
  end

  get '/memos/new' do
    erb :'new.html'
  end

  post '/memos' do
    validate_params(params, :'new.html')
    new_memo = Memo.new(params[:title], params[:content])
    memo_manager.add(new_memo)
    status 201 # TODO: 不要？
    redirect '/'
  end

  get '/memos/:id/detail' do
    memo_id = params['id']
    memo = memo_manager.find(memo_id)
    @memo = memo

    erb :'detail.html'
  end

  get '/memos/:id/edit' do
    memo_id = params['id']
    memo = memo_manager.find(memo_id)
    @memo = memo
    erb :'edit.html'
  end

  put '/memos/:id' do
    memo_id = params['id']
    memo = memo_manager.find(memo_id)

    @memo = memo

    validate_params(params, :'edit.html')

    memo.title = params[:title]
    memo.content = params[:content]
    memo.updated_at = Time.now

    status 200
    redirect "/memos/#{memo_id}/detail"
  end

  not_found do
    @error_message = 'This is nowhere to be found.'
    erb :'error.html'
  end

  get '/info' do
    puts response

    status 418
    headers 'Content-Type' => 'text/plain'
    body 'I am a teapot'
  end
end
