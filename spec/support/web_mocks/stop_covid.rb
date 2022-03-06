# frozen_string_literal: true

module WebMocks
  module StopCovid
    class << self
      def get_region_stats(args = {})
        args.reverse_merge!(region_id: CovidStat::FETCHABLE_REGIONS.sample)

        body = (30.days.ago.to_date..1.day.ago.to_date).map { |date| stat(date) }
        mock = ::WebMock.stub_request(:get, endpoint(args[:region_id]))
                        .to_return(status: 200, body: body.to_json)

        { mock: mock, body: body, args: args }
      end

      private

      def stat(date)
        model_data = FactoryBot.attributes_for(:covid_stat, date: date).except(:region)
        model_data[:date] = model_data[:date].strftime('%d.%m.%Y')
        model_data
      end

      def endpoint(region_id)
        "#{Rails.configuration.secrets[:stop_covid_url]}/covid_data.json?do=region_stats&code=RU-#{region_id.upcase}"
      end
    end
  end
end
