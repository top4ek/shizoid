# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.1'

gem 'faraday'
gem 'pg'
gem 'puma'
gem 'rails'
gem 'redis'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'sidekiq-limit_fetch', github: 'brainopia/sidekiq-limit_fetch', ref: 'bf9cee3b81e49ab8002bb9d564c2002d5b8a4b56'
gem 'telegram-bot-ruby'

group :development, :test do
  gem 'debug'
  gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'guard'
  gem 'guard-rake'
  gem 'guard-rspec'
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
