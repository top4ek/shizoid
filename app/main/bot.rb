module Bot

  class Base

    def initialize
      Bot.logger.info 'Initializing bot'
      Dir.glob("#{Bot.configuration.root}/app/models/*.rb").each{|f| require f}
      connection_details = YAML::load(File.open("#{Bot.configuration.root}/config/database.yml"))
      ActiveRecord::Base.establish_connection(connection_details)
    end

    def run
      Bot.logger.info 'Starting bot'
      Telegram::Bot::Client.run Bot.configuration.telegram_token do |bot|
        bot.listen do |msg|
          Message.new(bot, msg).process
        end
      end
    end

  end
end
