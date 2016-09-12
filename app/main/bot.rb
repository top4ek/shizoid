module Bot

  def self.redis
    @redis ||= Redis.new(url: Bot.configuration.redis_url)
  end

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
          begin
            Message.new(bot, msg).process
          rescue Exception => error
            Bot.logger.error "#{error}"
          end
        end
      end
    end

  end
end
