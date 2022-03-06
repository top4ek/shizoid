# frozen_string_literal: true

# pg_restore -vvv -Fc -h 127.0.0.1 -p 5555 -U shizoid -c -d shizoid < /tmp/dump.backup
# pg_dump -Fc -v -d shizoid > /tmp/dump.backup

namespace :db do
  desc 'Dumps the database'
  task dump: :environment do
    db_config = ActiveRecord::Base.connection_config
    host = db_config[:host]
    db = db_config[:database]
    port = db_config[:port]
    user = db_config[:username]
    pass = db_config[:password]
    time = Time.current.strftime('%Y%m%d%H%M%S')
    full_path = "#{backup_directory}/#{time}_#{db}.backup"

    system "pg_dump -Fc -d 'postgres://#{user}:#{pass}@#{host}:#{port}/#{db}' -f '#{full_path}'"
    puts "\nDumped to file: #{full_path}\n"
  end

  desc 'Show the existing database backups'
  task dumps: :environment do
    system "/bin/ls -ltR #{backup_directory}"
  end

  desc 'Restores the database from a backup'
  task restore: :environment do
    time = ENV['time']
    files = Dir.glob("#{backup_directory}/**/#{time}*.backup")
    file = nil
    case files.size
    when 0
      puts 'Backup not found.'
    when 1
      file = files.first
    else
      puts 'Ambiguous time specified.'
    end

    if file.present?
      db_config = ActiveRecord::Base.connection_config
      host = db_config[:host]
      db = db_config[:database]
      port = db_config[:port]
      user = db_config[:username]
      pass = db_config[:password]
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      cmd = "pg_restore -Fc -d 'postgres://#{user}:#{pass}@#{host}:#{port}/#{db}' < '#{file}'"
      system cmd
      puts "\nRestored from file: #{file}\n"
    end
  end

  private

  def backup_directory
    backup_dir = File.join(Rails.root, 'db/backups')
    return backup_dir if Dir.exist?(backup_dir)

    puts "Creating #{backup_dir}..."
    FileUtils.mkdir_p(backup_dir)
    backup_dir
  end
end
