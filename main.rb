# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'rack/protection'

require_relative 'db/db'
require_relative 'route/api'
require_relative 'models/memo'
require_relative 'helpers/validate'

set :show_exceptions, false

class App < Sinatra::Base
  extend DB
  configure { DB.connect! }

  set :method_override, true

  use Rack::Protection::ContentSecurityPolicy,
      default_src: "'self'",
      script_src: "'self' https://cdn.jsdelivr.net",
      style_src: "'self' https://cdn.jsdelivr.net 'unsafe-inline'"
  use ApiRoute

  helpers Validate

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

  before %r{/memos/([a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12})(?:/.*)?} do
    memo_id = @params['captures'].first
    @memo = Memo.find(memo_id)
    halt 404 unless @memo
  end

  get '/' do
    @memos = Memo.all

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

    Memo.add(title: params[:title], content: params[:content])

    redirect '/'
  end

  get '/memos/:id/detail' do
    content_type :html
    erb :'detail.html' do
      @header_left = "<a href='/' class='underline'>back to home</a>"
      @header_center = "<h2 class='text-xl'>#{h @memo.title}</h2>"
      @header_right = "<p class='text-sm text-gray-500 items-end'>last update: #{@memo.updated_at.strftime('%F %H:%M')}</p>"
      erb :'header.html'
    end
  end

  get '/memos/:id/edit' do
    content_type :html
    erb :'edit.html' do
      @header_left = "<a href='/' class='underline'>back to home</a>"
      @header_center = "<h2 class='text-xl'>#{h @memo.title}</h2>"
      erb :'header.html'
    end
  end

  patch '/memos/:id' do
    validate_params(params, :'edit.html')

    Memo.update(id: params[:id], title: params[:title], content: params[:content])

    redirect "/memos/#{params['id']}/detail"
  end

  delete '/memos/:id' do
    Memo.delete(params[:id])
    redirect '/'
  end

  not_found do
    @error_message ||= 'Not found.'
    erb :'error.html'
  end
end
