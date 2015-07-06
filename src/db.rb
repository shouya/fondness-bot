require 'sequel'

class DB
  DEFAULT_DB_PATH  = File.expand_path('../config/java.db', __FILE__)
  TWEETS_DATA_SET  = :tweets
  CURSORS_DATA_SET = :cursors
  CURSOR_DEFAULT_VALUE = '0'

  def init(db_path = DEFAULT_DB_PATH)
    @db = Sequel.sqlite(db_path)
    @cursor_cache = {}
    create_db unless File.exists? @db
  end

  def tweets
    @db[TWEETS_DATA_SET]
  end

  def cursors
    @db[CURSORS_DATA_SET]
  end

  def write_cursor(user, type, cursor)
    rec = cursors.where(user: user, type: type)
    if rec.update(curosr: cursor) != 1
      cursors.insert(user: user, type: type, cursor: cursor)
    end
  end

  def read_cursor(user, type)
    rec = cursors.where(user: user, type: type)
    return CURSORS_DEFAULT_VALUE if rec.count == 0
    rec.first[:cursor]
  end

  private

  def create_db
    @db.create_table TWEETS_DATA_SET do
      primary_key :id
      String :owner
      String :content
      String :type
      String :tweet_id
      String :ref_tweet_id # for reply
      Integer :rt_counts
      Integer :fav_counts
      DateTime :timestamp

      index :owner
      index :content
      index :type
      index :ref_tweet_id
      index :tweet_id
      index :timestamp
    end

    @db.create_table CURSORS_DATA_SET do
      primary_key :id
      String :user
      String :type
      String :cursor

      index :user
    end
  end

end
