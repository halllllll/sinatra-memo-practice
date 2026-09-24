# frozen_string_literal: true

require 'pg'
require 'pathname'

module DB
  def self.connect!
    @conn = PG::Connection.new(
      host: ENV['DB_HOST'],
      user: ENV['DB_USER'],
      dbname: ENV['DB_NAME'],
      port: ENV['DB_PORT'],
      password: ENV['DB_PASS']
    )

    @conn.field_name_type = :symbol

    sql = Pathname(__dir__).join('init.sql').read
    @conn.exec(sql)
  end

  def self.conn
    @conn || raise('db not connected yet')
  end
end
