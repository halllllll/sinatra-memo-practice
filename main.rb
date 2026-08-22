# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'time'

class Memo
  attr_accessor :title, :content, :updated_at
  attr_reader :created_at, :id

  def initialize(id, title, content)
    @id = id
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
    puts "post data: #{params}"
    # TODO: バリデーションなどはあとでやる
    new_memo = Memo.new(@memos.size + 1, params[:title], params[:content])
    @memos << new_memo

    redirect '/memos'
  end

  get '/memos/:id' do
    params['id']
  end

  get '/info' do
    puts response

    status 418
    headers 'Content-Type' => 'text/plain'
    body 'I am a teapot'
  end
end
