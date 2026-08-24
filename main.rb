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
  def initialize
    super
    @memos = []
  end

  get '/' do
    erb :'index.html'
  end

  get '/memos/new' do
    erb :'new.html'
  end

  post '/memos' do
    status 400
    @error_message = 'required parameter not found'
    return erb :'new.html' if [params[:title], params[:content]].any?(nil)

    @error_message = 'empty value not acceptable'
    return erb :'new.html' if [params[:title], params[:content]].map(&:strip).any?(&:empty?)

    new_memo = Memo.new(params[:title], params[:content])
    @memos << new_memo
    status 201 # TODO: 不要？
    redirect '/'
  end

  get '/memos/:id/detail' do
    target_id = params['id']
    memo = @memos.find { |memo| memo.id == target_id }
    @memo = memo
    erb :'detail.html'
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
