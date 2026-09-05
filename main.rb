# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'rack/protection'
require 'time'

require_relative 'route/api'
require_relative 'models/memo'
require_relative 'helpers/validate'

set :show_exceptions, false

class App < Sinatra::Base
  set :method_override, true
  set :memo_manager, MemoManager.new

  use Rack::Protection::EscapedParams
  use Rack::Protection::ContentSecurityPolicy,
      default_src: "'self'",
      script_src: "'self' https://cdn.jsdelivr.net",
      style_src: "'self' https://cdn.jsdelivr.net 'unsafe-inline'"
  use ApiRoute, settings.memo_manager

  helpers do
    def memo_manager
      settings.memo_manager
    end
  end

  helpers Validate

  before %r{/memos/([a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12})(?:/.*)?} do
    memo_id = @params['captures'].first
    @memo = memo_manager.find(memo_id)
    halt 404 unless @memo
  end

  get '/' do
    @memos = memo_manager.memos

    content_type :html
    erb :'index.html' do
      @header_center = "<h2 class='text-xl'>Memos</h2>"

      erb :'header.html'
    end
  end

  get '/memos/new' do
    content_type :html
    erb :'new.html' do
      @header_left = "<a href='/' class='underline'>back to home</a>"
      @header_center = "<h2 class='text-xl'>New memo</h2>"

      erb :'header.html'
    end
  end

  post '/memos' do
    validate_params(params, :'new.html')
    new_memo = Memo.new(title: params[:title], content: params[:content])
    memo_manager.add(new_memo)

    redirect '/'
  end

  get '/memos/:id/detail' do
    content_type :html
    erb :'detail.html' do
      @header_left = "<a href='/' class='underline'>back to home</a>"
      @header_center = "<h2 class='text-xl'>#{@memo.title}</h2>"
      @header_right = "<p class='text-sm text-gray-500 items-end'>last update: #{@memo.updated_at.strftime('%F %H:%M')}</p>"
      erb :'header.html'
    end
  end

  get '/memos/:id/edit' do
    content_type :html
    erb :'edit.html' do
      @header_left = "<a href='/' class='underline'>back to home</a>"
      @header_center = "<h2 class='text-xl'>#{@memo.title}</h2>"
      erb :'header.html'
    end
  end

  patch '/memos/:id' do
    validate_params(params, :'edit.html')

    edited_memo = Memo.new(id: params['id'], title: params['title'], content: params['content'], created_at: @memo.created_at, updated_at: Time.now)

    memo_manager.update(edited_memo)

    @memo = edited_memo
    redirect "/memos/#{params['id']}/detail"
  end

  delete '/memos/:id' do
    memo_manager.delete(params[:id])
    redirect '/'
  end

  not_found do
    @error_message ||= 'Not found.'
    erb :'error.html'
  end
end
