require 'sequel'
require 'singleton'

class DBClass
  include Singleton

  DEFAULT_DB_PATH = File.expand_path('../../data/data.db', __FILE__)

  def initialize(db_path = DEFAULT_DB_PATH)
    @db = Sequel.sqlite(db_path)
  end

  def messages
    @db[:messages]
  end

  def cursors
    @db[:cursors]
  end

  def write_cursor(type, cursor)
    rec = cursors.where(type: type)
    if rec.update(curosr: cursor) != 1
      cursors.insert(type: type, cursor: cursor)
    end
  end

  def read_cursor(type)
    rec = cursors.where(type: type)
    return nil if rec.count == 0
    rec.first[:cursor]
  end
end

DB = DBClass.instance
