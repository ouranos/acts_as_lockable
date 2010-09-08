class ActsAsLockableGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      if defined?(ActiveRecord)
        m.migration_template "migration.rb", 'db/migrate',
                             :migration_file_name => "create_locks"
      end
    end
  end
end
