Sequel.migration do
  change do
    create_table(:cursors) do
      primary_key :id
      String :cursor, :size=>255
      String :type, :size=>255
    end
    
    create_table(:lists) do
      primary_key :id
      String :list, :size=>255
      String :content, :size=>255
      DateTime :created_at
    end
    
    create_table(:messages, :ignore_index_errors=>true) do
      primary_key :id
      Integer :message_id, :null=>false
      Integer :from, :null=>false
      Integer :to, :null=>false
      String :text, :size=>255
      String :type, :size=>255, :null=>false
      String :media_type, :size=>255
      String :media, :size=>255
      DateTime :created_at
      DateTime :logged_at
      
      index [:created_at]
      index [:from]
      index [:logged_at]
      index [:media_type]
      index [:message_id]
      index [:to]
      index [:type]
    end
  end
end
