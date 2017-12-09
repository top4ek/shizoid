set :rails_env, 'production'
server "#{fetch :server_address}", user: "#{fetch :deploy_user}", roles: %w{app db web}, port: "#{fetch :ssh_port}"
