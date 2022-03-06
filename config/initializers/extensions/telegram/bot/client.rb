# frozen_string_literal: true

# Monkeypatch gem to return plain json in polling mode

module Telegram
  module Bot
    class Client
      def fetch_updates
        response = api.getUpdates(options)
        return unless response['ok']

        response['result'].each do |data|
          update = Types::Update.new(data)
          @options[:offset] = update.update_id.next
          log_incoming_message(data)
          yield data
        end
      rescue Faraday::TimeoutError
        retry
      end
    end
  end
end
