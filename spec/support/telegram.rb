# frozen_string_literal: true

module FFaker
  module Telegram
    class << self
      extend ModuleUtils

      def bot_token
        "#{user_id}:#{SecureRandom.hex}"
      end

      def user_id
        FFaker::Random.rand(-2**52..2**52)
      end
    end
  end
end
