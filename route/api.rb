# frozen_string_literal: true

require_relative '../db/db'

class ApiRoute < Sinatra::Base
  get '/api/memos' do
    json({ result: 'success', body: Memo.all.map(&:to_json) })
  end

  post '/api/memos' do
    halt 400, json({ result: 'error', message: 'required parameter not found' }) if [params[:title], params[:content]].any?(nil)
    halt 400, json({ result: 'error', message: 'empty value not acceptable' }) if [params[:title], params[:content]].map(&:strip).any?(&:empty?)

    new_memo = Memo.new(title: params[:title], content: params[:content])
    Memo.add(new_memo)

    status 201
    json({ result: 'success', body: new_memo.to_json })
  end

  get '/api/memos/:id' do
    memo_id = params[:id]
    memo = Memo.find(memo_id)
    halt 404, json({ result: 'error', message: 'memo not found' }) unless memo
    json({ result: 'success', body: memo.to_json })
  end

  patch '/api/memos/:id' do
    memo_id = params[:id]
    memo = Memo.find(memo_id)
    halt 404, json({ result: 'error', message: 'memo not found' }) unless memo
    halt 400, json({ result: 'error', message: 'invalid parameter' }) if [params[:title], params[:content]].any?(nil)

    memo.title = params[:title]
    memo.content = params[:content]
    memo.updated_at = Time.now

    Memo.update(memo)

    status 204
  end

  delete '/api/memos/:id' do
    memo_id = params[:id]
    memo = Memo.find(memo_id)
    halt 404, json({ result: 'error', message: 'memo not found' }) unless memo
    Memo.delete(memo.id)

    status 204
  end
end
