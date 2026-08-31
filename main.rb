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

  helpers Validate

  before '/memos/:id' do
    memo_id = @params[:id]
    target_memo = memo_manager.find(memo_id)
    @error_message = 'memo not found'
    halt 404, erb(:'error.html') unless target_memo
    @error_message = ''
  end

  get '/' do
    @memos = memo_manager.memos

    erb :'index.html' do
      @header_center = "<h2 class='text-xl'>Memos</h2>"

      erb :'header.html'
    end
  end

  get '/memos/new' do
    erb :'new.html' do
      @header_left = "<a href='/' class='underline'>back to home</a>"
      @header_center = "<h2 class='text-xl'>New memo</h2>"

      erb :'header.html'
    end
  end

  post '/memos' do
    validate_params(params, :'new.html')
    new_memo = Memo.new(params[:title], params[:content])
    memo_manager.add(new_memo)

    redirect '/'
  end

  get '/memos/:id/detail' do
    memo_id = params['id']
    memo = memo_manager.find(memo_id)
    @memo = memo

    erb :'detail.html' do
      @header_left = "<a href='/' class='underline'>back to home</a>"
      @header_center = "<h2 class='text-xl'>#{@memo.title}</h2>"
      @header_right = "<p class='text-sm text-gray-500 items-end'>last update: #{@memo.updated_at.strftime('%F %H:%M')}</p>"
      erb :'header.html'
    end
  end

  get '/memos/:id/edit' do
    memo_id = params['id']
    memo = memo_manager.find(memo_id)
    @memo = memo

    erb :'edit.html' do
      @header_left = "<a href='/' class='underline'>back to home</a>"
      @header_center = "<h2 class='text-xl'>#{@memo.title}</h2>"
      erb :'header.html'
    end
  end

  patch '/memos/:id' do
    memo_id = params['id']
    memo = memo_manager.find(memo_id)

    @memo = memo

    validate_params(params, :'edit.html')

    memo.title = params[:title]
    memo.content = params[:content]
    memo.updated_at = Time.now

    redirect "/memos/#{memo_id}/detail"
  end

  delete '/memos/:id' do
    memo_manager.delete(params[:id])
    redirect '/'
  end

  not_found do
    @error_message = @error_message.nil? || @error_message.empty? ? 'his is nowhere to be found.' : @error_message
    erb :'error.html'
  end
end
