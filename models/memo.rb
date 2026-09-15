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
      ensure_memo_file

      CSV.foreach(DATA_FILE, headers: true, header_converters: :symbol).map do |row|
        Memo.new(
          **row.to_h.slice(:id, :title, :content),
          created_at: Time.strptime(row[:created_at], DATE_FORMAT),
          updated_at: Time.strptime(row[:updated_at], DATE_FORMAT)
        )
      end
    end

    def add(memo)
      ensure_memo_file

      CSV.open(DATA_FILE, 'a') { |csv| csv << memo.to_a }
    end

    def update(memo)
      ensure_memo_file

      memo_table = CSV.read(DATA_FILE, headers: true, header_converters: :symbol)
      memo_table.each do |row|
        next if memo.id != row[:id]

        row[:title] = memo.title
        row[:content] = memo.content
        row[:updated_at] = memo.updated_at
      end
      CSV.open(DATA_FILE, 'w') do |csv|
        csv << memo_table.headers
        memo_table.each { |row| csv << row }
      end
    end

    def find(memo_id)
      all.find { |memo| memo.id == memo_id }
    end

    def delete(memo_id)
      memo_table = CSV.read(DATA_FILE, headers: true, header_converters: :symbol)
      memo_table.delete_if do |row|
        memo_id == row[:id]
      end
      CSV.open(DATA_FILE, 'w') do |csv|
        csv << memo_table.headers
        memo_table.each { |row| csv << row }
      end
    end

    private

    def ensure_memo_file
      return if File.exist?(DATA_FILE)

      CSV.open(DATA_FILE, 'w') do |csv|
        csv << %w[id title content created_at updated_at]
      end
    end
  end
end
