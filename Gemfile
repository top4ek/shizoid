source 'https://rubygems.org'

ruby '2.4.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.3'
gem 'pg'
gem 'puma', '~> 3.7'
gem 'redis'
gem 'sidekiq'
gem 'sidekiq-limit_fetch'
gem 'rack-cors'
gem 'newrelic_rpm'
gem 'telegram-bot'
gem 'telegram-bot-types'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development do
  gem 'capistrano', '~> 3.6'
  gem 'capistrano-rails', '~> 1.3'
  gem 'capistrano-rvm'
end

group :development, :test do
  gem 'ffaker'
  gem 'factory_bot_rails'
  gem 'listen'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-nav'
end
