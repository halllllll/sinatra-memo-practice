# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'time'
require 'securerandom'

# set :show_exceptions, false

class Memo
  attr_accessor :title, :content, :updated_at
  attr_reader :created_at, :id

  def initialize(title, content)
    @id = SecureRandom.uuid
    @title = title
    @content = content
    @created_at = Time.now
    @updated_at = Time.now
  end

  def to_json(*)
    instance_variables.map do |key|
      [key.to_s.tr('@', ''), instance_variable_get(key)]
    end.to_h
  end
end

class App < Sinatra::Base
  set :method_override, true

  def initialize
    super
    @memos = []
  end

  helpers do
    def pick_memo(memo_id)
      target_memo = @memos.find { |memo| memo.id == memo_id }
      @error_message = 'memo not found'
      halt 404, erb(:'index.html') unless target_memo

      target_memo
    end

    def validate_params(params, page)
      status 400
      @error_message = 'required parameter not found'
      halt 400, erb(page) if [params[:title], params[:content]].any?(nil)

      @error_message = 'empty value not acceptable'
      halt 400, erb(page) if [params[:title], params[:content]].map(&:strip).any?(&:empty?)
    end
  end

  get '/' do
    erb :'index.html'
  end

  get '/memos/new' do
    erb :'new.html'
  end

  post '/memos' do
    validate_params(params, :'new.html')
    new_memo = Memo.new(params[:title], params[:content])
    @memos << new_memo
    status 201 # TODO: 不要？
    redirect '/'
  end

  get '/memos/:id/detail' do
    target_id = params['id']
    memo = pick_memo(target_id)
    @memo = memo

    erb :'detail.html'
  end

  get '/memos/:id/edit' do
    target_id = params['id']
    memo = pick_memo(target_id)
    @memo = memo
    erb :'edit.html'
  end

  put '/memos/:id' do
    target_id = params['id']
    memo = pick_memo(target_id)
    @memo = memo

    validate_params(params, :'edit.html')

    memo.title = params[:title]
    memo.content = params[:content]
    memo.updated_at = Time.now

    status 200
    redirect "/memos/#{target_id}/detail"
  end

  not_found do
    @error_message = 'This is nowhere to be found.'
    erb :'error.html'
  end

  get '/api/memos' do
    json({ result: 'success', body: @memos.map(&:to_json) })
  end

  post '/api/memos' do
    halt 400, json({ result: 'error', message: 'required parameter not found' }) if [params[:title], params[:content]].any?(nil)
    halt 400, json({ result: 'error', message: 'empty value not acceptable' }) if [params[:title], params[:content]].map(&:strip).any?(&:empty?)

    new_memo = Memo.new(params[:title], params[:content])
    @memos << new_memo
    status 201 # TODO: 不要？
    redirect '/api/memos'
  end

  get '/api/memos/:id' do
    target_id = params['id']
    memo = @memos.find { |memo| memo.id == target_id }
    halt 400, json({ result: 'error', message: 'required parameter not found' }) if [params[:title], params[:content]].any?(nil)
    halt 400, json({ result: 'error', message: 'empty value not acceptable' }) if [params[:title], params[:content]].map(&:strip).any?(&:empty?)

    json({ result: 'success', body: memo.to_json })
  end

  put '/api/memos/:id' do
    target_id = params['id']
    memo = @memos.find { |memo| memo.id == target_id }
    halt 404, json({ result: 'error', message: 'memo not found' }) unless memo
    halt 400, json({ result: 'error', message: 'invalid parameter' }) if [params[:title], params[:content]].any?(nil)

    memo.title = params[:title]
    memo.content = params[:content]
    memo.updated_at = Time.now

    status 204
  end

  delete '/api/memos/:id' do
    target_id = params['id']
    memo = @memos.find { |memo| memo.id == target_id }
    halt 404, json({ result: 'error', message: 'memo not found' }) unless memo

    target_index = @memos.find_index(memo)
    @memos.delete_at(target_index)

    status 204
  end

  get '/info' do
    puts response

    status 418
    headers 'Content-Type' => 'text/plain'
    body 'I am a teapot'
  end
end
