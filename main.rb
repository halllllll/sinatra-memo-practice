# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'time'
require 'securerandom'

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

  get '/memos' do
    json({ memos: @memos.map(&:to_json) })
  end

  post '/memos' do
    halt 400, json({ result: 'error', message: 'invalid parameter' }) if [params[:title], params[:content]].any?(nil)

    new_memo = Memo.new(params[:title], params[:content])
    @memos << new_memo
    status 201 # 不要？
    redirect '/memos'
  end

  get '/memos/:id' do
    target_id = params['id']
    memo = @memos.find { |memo| memo.id == target_id }
    halt 404, json({ result: 'error', message: 'memo not found' }) unless memo

    json({ result: 'success', body: memo.to_json })
  end

  put '/memos/:id' do
    target_id = params['id']
    memo = @memos.find { |memo| memo.id == target_id }
    halt 404, json({ result: 'error', message: 'memo not found' }) unless memo

    target_index = @memos.find_index(memo)

    halt 400, json({ result: 'error', message: 'invalid parameter' }) if [params[:title], params[:content]].any?(nil)

    new_memo = Memo.new(params[:title], params[:content])
    new_memo.updated_at = Time.now
    @memos[target_index] = new_memo

    redirect '/'
  end

  get '/info' do
    puts response

    status 418
    headers 'Content-Type' => 'text/plain'
    body 'I am a teapot'
  end
end
