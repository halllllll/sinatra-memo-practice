# frozen_string_literal: true

require 'csv'
require 'securerandom'

DATA_FILE = 'memos.csv'
DATE_FORMAT = '%Y-%m-%d %H:%M:%S'

class Memo
  attr_accessor :title, :content, :updated_at
  attr_reader :id, :created_at

  def initialize(
    title:,
    content:,
    id: SecureRandom.uuid,
    created_at: Time.now,
    updated_at: Time.now
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
    def all
      result = DB.conn.exec('SELECT * FROM memos')
      result.field_name_type = :symbol
      result.map do |row|
        Memo.new(
          **row.slice(:id, :title, :content),
          created_at: Time.strptime(row[:created_at], DATE_FORMAT),
          updated_at: Time.strptime(row[:updated_at], DATE_FORMAT)
        )
      end
    end

    def add(memo)
      DB.conn.exec_params('INSERT INTO memos(title, content) VALUES($1, $2)', [memo.title, memo.content])
    end

    def update(memo)
      DB.conn.exec_params('UPDATE memos SET title = $2, content = $3, updated_at = $4 WHERE id = $1', [memo.id, memo.title, memo.content, memo.updated_at])
    end

    def find(memo_id)
      result = DB.conn.exec_params('SELECT * FROM memos WHERE id = $1', [memo_id])
      return nil if result.ntuples.zero?

      result.field_name_type = :symbol
      row = result.first
      Memo.new(
        **row.slice(:id, :title, :content),
        created_at: Time.strptime(row[:created_at], DATE_FORMAT),
        updated_at: Time.strptime(row[:updated_at], DATE_FORMAT)
      )
    end

    def delete(memo_id)
      DB.conn.exec_params('DELETE FROM memos WHERE id = $1', [memo_id])
    end
  end
end
