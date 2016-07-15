module Bot

  class FakeMessage
    class Chat
      attr_reader :id, :type
      def initialize
        @id = 0
        @type = 'private'
      end
    end

    attr_reader :text, :chat, :type, :message_id, :migrate_to_chat_id

    def initialize(message)
      @text = message
      @type = 'private'
      @chat = FakeMessage::Chat.new
      @message_id = 0
      @migrate_to_chat_id = nil
    end

  end

  class FakeBot
    class Api
      def send_message(*options)
        puts ">>> #{options[0][:text]}"
      end
    end
    attr_reader :api
    def initialize
      @api = FakeBot::Api.new
    end
  end

  class Base
    def console_reader
      begin
        print '<<< '
        str = gets
        message = Message.new(FakeBot.new, FakeMessage.new(str))
        Pair.learn message if message.has_text?
        message.reply Pair.generate(message) if message.has_text?
      end while str || str != 'exit'
    end
  end
end
