require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rvm'
require 'capistrano/bundler'
require 'capistrano/rails/migrations'

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
Dir.glob('lib/capistrano/**/*.rb').each { |r| import r }
