# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.3'

gem 'faraday'
gem 'pg'
gem 'puma'
gem 'rails', '~> 7.0.3'
gem 'redis'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'
gem 'sidekiq', '< 7'
gem 'sidekiq-cron'
gem 'sidekiq-limit_fetch'
gem 'telegram-bot-ruby', '~> 0.23.0'

group :development, :test do
  gem 'debug'
  gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-rake', require: false
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'listen'
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'webmock'
end

group :development do
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :test do
  gem 'database_cleaner'
  gem 'rspec-sidekiq'
  gem 'simplecov', require: false
end
