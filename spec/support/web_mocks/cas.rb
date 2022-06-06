# frozen_string_literal: true

module WebMocks
  module Cas
    class << self
      def check(args = {})
        args.reverse_merge!(telegram_id: rand(999), banned: false)

        body = if args[:banned]
                 { ok: true, result: { offenses: 1, messages: ['test'], time_added: '2022-05-01T10:50:19.000Z' } }
               else
                 { ok: false, description: 'Record not found.' }
               end

        mock = ::WebMock.stub_request(:get, endpoint(args[:telegram_id]))
                        .to_return(status: 200, body: body.to_json)

        { mock:, body:, args: }
      end

      private

      def endpoint(telegram_id)
        "#{Rails.configuration.secrets[:cas_url]}/check?user_id=#{telegram_id}"
      end
    end
  end
end
