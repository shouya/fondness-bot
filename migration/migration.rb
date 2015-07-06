
require 'sequel'

DB_PATH = File.expand_path('../../data/data.db', __FILE__)

$db = Sequel.sqlite(DB_PATH)
