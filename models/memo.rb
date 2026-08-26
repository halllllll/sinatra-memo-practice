# frozen_string_literal: true

class MemoManager
  attr_reader :memos

  def initialize
    @memos = []
  end

  # TODO: title,contentを受取り、ここでMemoをnewする？
  def add(memo)
    @memos << memo
  end

  def find(memo_id)
    @memos.find { |memo| memo.id == memo_id }
  end

  def delete(memo_id)
    target_memo = find(memo_id)
    @memos.reject! { |memo| memo == target_memo }
  end
end

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
