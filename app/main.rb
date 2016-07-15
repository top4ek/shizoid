require 'rubygems'
require 'bundler/setup'
require 'telegram/bot'
require 'active_record'
require 'logger'
require 'pg'
require 'i18n'
require 'unicode'
require 'yaml'
require 'logger'
require 'digest/sha1'
require 'date'

require_relative 'main/configuration.rb'
require_relative 'main/message.rb'
require_relative 'main/bot.rb'
require_relative 'main/logger.rb'
#require_relative 'main/readline.rb'

bot = Bot::Base.new
bot.run
# bot.console_reader
