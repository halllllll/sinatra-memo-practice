# frozen_string_literal: true

require 'pg'
require 'pathname'

module DB
  def self.connect!
    @conn = PG::Connection.new(
      host: 'localhost',
      user: 'memo_app',
      dbname: 'memo_db',
      port: '5678',
      password: 'memo_pass'
    )

    @conn.field_name_type = :symbol

    sql = Pathname(__dir__).join('init.sql').read
    @conn.exec(sql)
  end

  def self.conn
    @conn || raise('db not connected yet')
  end
end
