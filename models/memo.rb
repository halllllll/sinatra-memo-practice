# frozen_string_literal: true

require 'time'

class Memo
  attr_accessor :title, :content, :updated_at
  attr_reader :id, :created_at

  DATE_FORMAT = '%Y-%m-%d %H:%M:%S'

  def initialize(
    title:,
    content:,
    id: nil,
    created_at: nil,
    updated_at: nil
  )
    @id = id
    @title = title
    @content = content
    @created_at = created_at
    @updated_at = updated_at
  end

  def to_a
    [id, title, content, created_at, updated_at]
  end

  def to_json(*)
    instance_variables.map do |key|
      [key.to_s.tr('@', ''), instance_variable_get(key)]
    end.to_h
  end

  class << self
    def from_row(row)
      new(**row.slice(:id, :title, :content),
        created_at: Time.strptime(row[:created_at], DATE_FORMAT),
        updated_at: Time.strptime(row[:updated_at], DATE_FORMAT))
    end

    def all
      result = DB.conn.exec('SELECT * FROM memos ORDER BY memos.created_at')

      result.map do |row|
        Memo.from_row(row)
      end
    end

    def add(title:, content:)
      result = DB.conn.exec_params('INSERT INTO memos(title, content) VALUES($1, $2) RETURNING *', [title, content])

      Memo.from_row(result.first)
    end

    def update(id:, title:, content:)
      result = DB.conn.exec_params('UPDATE memos SET title = $2, content = $3, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *', [id, title, content])

      Memo.from_row(result.first)
    end

    def find(memo_id)
      result = DB.conn.exec_params('SELECT * FROM memos WHERE id = $1', [memo_id])
      return nil if result.ntuples.zero?

      Memo.from_row(result.first)
    end

    def delete(memo_id)
      DB.conn.exec_params('DELETE FROM memos WHERE id = $1', [memo_id])
    end
  end
end
