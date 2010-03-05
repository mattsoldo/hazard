namespace :db do
  namespace :backup do
    desc "Dumps the database for the current environment into db/env-data.sql.bz2."
    task :dump => :environment do
      abc = ActiveRecord::Base.configurations[RAILS_ENV]
      case abc['adapter']
      when 'mysql'
        cmd = ['mysqldump']
        cmd << "--host='#{abc['host']}'" unless abc['host'].blank?
        cmd << "--user='#{abc['username'].blank? ? 'root' : abc['username']}'"
        cmd << "--password='#{abc['password']}'" unless abc['password'].blank?
        cmd << abc['database']
        cmd << " | bzip2 > #{RAILS_ROOT}/db/#{RAILS_ENV}-data.sql.bz2"
        sh cmd.flatten.join ' '  
      when 'postgresql'
        if abc['password'].blank? 
          cmd = ['pg_dump']
        else
          cmd = ["export PGPASSWORD='#{abc['password']}';pg_dump"] 
        end
        cmd << "--host='#{abc['host']}'" unless abc['host'].blank?
        cmd << "--port='#{abc['port']}'" unless abc['port'].blank?
        cmd << "--username='#{abc['username'].blank? ? 'root' : abc['username']}'"
        cmd << abc['database']
        cmd << " | bzip2 > #{RAILS_ROOT}/db/#{RAILS_ENV}-data.sql.bz2"  
        sh cmd.flatten.join ' '  
      else
        raise "Task not supported by '#{abc['adapter']}'."
      end
    end

    desc <<-TEXT
Loads an existing database dump into the current environment's database.
WARNING: this completely nukes the existing database! Use SOURCE_ENV to
specify which dump should be loaded. Defaults to 'production'."
TEXT
    task :load => [ :environment, "db:drop", "db:create" ] do
      source_env = ENV['SOURCE_ENV'] || 'production'

      abc = ActiveRecord::Base.configurations[RAILS_ENV]
      case abc['adapter']
      when 'mysql'
        cmd = ["bzcat #{RAILS_ROOT}/db/#{source_env}-data.sql.bz2 | mysql"]
        cmd << "--host='#{abc['host']}'" unless abc['host'].blank?
        cmd << "--user='#{abc['username'].blank? ? 'root' : abc['username']}'"
        cmd << "--password='#{abc['password']}'" unless abc['password'].blank?
        cmd << abc['database']
        sh cmd.flatten.join ' '
      when 'postgresql'
        if abc['password'].blank? 
          cmd = ['bzcat #{RAILS_ROOT}/db/#{source_env}-data.sql.bz2 | psql']
        else
          cmd = ["export PGPASSWORD='#{abc['password']}';bzcat #{RAILS_ROOT}/db/#{source_env}-data.sql.bz2 | psql"] 
        end
        cmd << "--host='#{abc['host']}'" unless abc['host'].blank?
        cmd << "--port='#{abc['port']}'" unless abc['port'].blank?
        cmd << "--username='#{abc['username'].blank? ? 'root' : abc['username']}'"
        cmd << abc['database']
        sh cmd.flatten.join ' '  
      else
        raise "Task not supported by '#{abc['adapter']}'."
      end
    end
  end
end
