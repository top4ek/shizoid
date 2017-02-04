set :application, 'shizoid'
set :deploy_user, 'alex'
set :server_address, '10.0.0.2'

set :scm, :git
set :format, :pretty
set :repo_url, 'git@github.com:top4ek/shizoid.git'
set :rvm_type, :user
set :rvm_ruby_version, "2.4.0"
set :deploy_to, "/home/#{fetch :deploy_user}/#{fetch :application}"
set :log, "#{fetch :deploy_to}/log"
set :keep_releases, 3

set :linked_files, %w{config/database.yml config/options.yml}
set :linked_dirs, %w{log run tmp}

set :config_files, %w(shizoid.service)  # sidekiq-shizoid.service
set(:symlinks, [
  { source: "shizoid.service",         link: "/etc/systemd/system/#{fetch :application}.service" },
  # { source: "sidekiq-shizoid.service", link: "/etc/systemd/system/sidekiq-#{fetch :application}.service" }
])

before 'deploy', 'deploy:generate_config_files'
before 'deploy:setup', 'deploy:generate_config_files'
after 'deploy:finished', 'deploy:restart'
