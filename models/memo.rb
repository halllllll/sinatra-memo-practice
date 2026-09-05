# frozen_string_literal: true

require 'csv'
require 'securerandom'

DATA_FILE = 'memos.csv'

class MemoManager
  def initialize
    return if File.exist?(DATA_FILE)

    CSV.open(DATA_FILE, 'w') do |csv|
      csv << %w[id title content created_at updated_at]
    end
  end

  def memos
    memo_arr = []
    CSV.foreach(DATA_FILE, headers: true) do |row|
      memo = Memo.new(
        id: row['id'],
        title: row['title'],
        content: row['content'],
        created_at: Time.strptime(row['created_at'], '%Y-%m-%d %H:%M:%S'),
        updated_at: Time.strptime(row['updated_at'], '%Y-%m-%d %H:%M:%S')
      )
      memo_arr << memo
    end
    memo_arr
  end

  def add(memo)
    CSV.open(DATA_FILE, 'a') { |csv| csv << memo.to_array }
  end

  def update(memo)
    memo_table = CSV.read(DATA_FILE, headers: true)
    memo_table.each do |row|
      next if memo.id != row['id']

      row['title'] = memo.title
      row['content'] = memo.content
      row['updated_at'] = memo.updated_at
    end
    CSV.open(DATA_FILE, 'w') do |csv|
      csv << memo_table.headers
      memo_table.each { |row| csv << row }
    end
  end

  def find(memo_id)
    memos.find { |memo| memo.id == memo_id }
  end

  def delete(memo_id)
    memo_table = CSV.read(DATA_FILE, headers: true)
    memo_table.delete_if do |row|
      memo_id == row['id']
    end
    CSV.open(DATA_FILE, 'w') do |csv|
      csv << memo_table.headers
      memo_table.each { |row| csv << row }
    end
  end
end

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

  def to_array
    [id, title, content, created_at, updated_at]
  end

  def to_json(*)
    instance_variables.map do |key|
      [key.to_s.tr('@', ''), instance_variable_get(key)]
    end.to_h
  end
end
