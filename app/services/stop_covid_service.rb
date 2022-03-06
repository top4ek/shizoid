# frozen_string_literal: true

module StopCovidService
  class << self
    ALLOWED_PARAMS = %i[date sick healed died first second].freeze

    def get_data(region_id)
      body = Faraday.get(url(region_id)).body
      json = JSON.parse(body).map(&:symbolize_keys)
      json.map do |record|
        new_date = Date.parse(record[:date])
        record.slice(*ALLOWED_PARAMS).except(:date).merge(date: new_date)
      end
    end

    private

    def url(region_id)
      "#{Rails.configuration.secrets[:stop_covid_url]}/covid_data.json?do=region_stats&code=RU-#{region_id.upcase}"
    end
  end
end
