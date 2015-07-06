
class Migrate
  def load_migration(file)
    path = if File.exists?
             file
           else
             File.expand_path('../migration/migrate', __FILE__)
           end
  end

  def migrate

  end
end

if __FILE__ == $0
  Migrate.new.migrate(*ARGV)
end
