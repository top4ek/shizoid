namespace :deploy do
  task :restart do
    on roles(:app, :web) do
      sudo 'systemctl daemon-reload'
      sudo "systemctl restart #{fetch :application}.service"
      sudo "systemctl restart #{fetch :application}_sidekiq.service"
      sudo 'systemctl reload nginx.service'
    end
  end

  task :setup do
    on roles(:app, :web) do
      symlinks = fetch(:symlinks)
      linked_files = fetch :linked_files

      symlinks.each do |symlink|
        sudo "ln -nfs #{shared_path}/config/#{symlink[:source]} #{sub_strings(symlink[:link])}"
      end

      linked_files.each do |file|
        upload! "#{file}.example", "#{shared_path}/#{file}"
      end

      sudo "systemctl enable #{fetch :application}.service"
      sudo "systemctl enable #{fetch :application}_sidekiq.service"
    end
  end

  task :generate_config_files do
    on roles(:app, :web) do
      execute :mkdir, "-p #{shared_path}/config"
      config_files = fetch :config_files
      config_files.each { |file| upload_template file }
    end
  end
end

def upload_template(from, to=nil)
  to ||= from
  full_to_path = "#{shared_path}/config/#{to}"
  erb = ERB.new(File.new("config/deploy/#{from}.erb").read).result(binding)
  upload! StringIO.new(erb), full_to_path
  execute :chmod, "644 #{full_to_path}"
end

def sub_strings(input_string)
  output_string = input_string
  input_string.scan(/{{(\w*)}}/).each do |var|
    output_string.gsub!("{{#{var[0]}}}", fetch(var[0].to_sym))
  end
  output_string
end
