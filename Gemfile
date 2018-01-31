source 'https://rubygems.org'

ruby '2.5.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'newrelic_rpm'
gem 'pg', '~> 0.21'
gem 'puma', '~> 3.7'
gem 'rack-cors'
gem 'rails', '~> 5.1.3'
gem 'redis'
gem 'sidekiq'
gem 'sidekiq-limit_fetch'
gem 'telegram-bot'
gem 'telegram-bot-types'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development do
  gem 'capistrano', '~> 3.6'
  gem 'capistrano-rails', '~> 1.3'
  gem 'capistrano-rvm'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'listen'
  gem 'localer'
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rails'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'rubocop'
end
