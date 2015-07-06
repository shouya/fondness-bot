require_relative 'migration'

$db.create_table? :messages do
  primary_key :id
  Integer     :message_id, null: false
  Integer     :from,       null: false
  Integer     :to,         null: false
  String      :text
  String      :type,       null: false
  String      :media_type
  String      :media
  DateTime    :created_at
  DateTime    :logged_at
end
