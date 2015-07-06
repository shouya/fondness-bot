require_relative 'migration'

$db.create_table? :cursors do
  primary_key :id
  String :cursor
  String :type
end

$db.alter_table :messages do
  add_index :message_id
  add_index :from
  add_index :to
  add_index :type
  add_index :media_type
  add_index :created_at
  add_index :logged_at
end
