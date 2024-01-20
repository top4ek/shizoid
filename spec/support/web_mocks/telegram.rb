# frozen_string_literal: true

module WebMocks
  module Telegram
    class << self
      def set_webhook(_args)
        url = "#{endpoint}/setWebhook"
        ::WebMock.stub_request(:post, url).to_return(status: 200, body: 'true')
      end

      def delete_message(_args)
        url = "#{endpoint}/deleteMessage"
        ::WebMock.stub_request(:post, url).to_return(status: 200, body: 'true')
      end

      def send_message(_args)
        url = "#{endpoint}/sendMessage"
        ::WebMock.stub_request(:post, url).to_return(status: 200, body: 'true')
      end

      private

      def endpoint
        "https://api.telegram.org/bot#{Rails.configuration.secrets[:telegram][:token]}"
      end
    end
  end
end
