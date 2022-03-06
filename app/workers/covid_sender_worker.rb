# frozen_string_literal: true

class CovidSenderWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    dates = CovidStat.group(:region).maximum(:date)
    dates['ALL'] = dates.values.max
    Chat.active.where.not(covid_region: nil).each do |c|
      next if c.covid_last_notification.present? && c.covid_last_notification >= dates[c.covid_region]

      c.update!(covid_last_notification: dates[c.covid_region])
      parameters = { text: CovidStat.day_stats(region: c.covid_region, return_i18n: true),
                     parse_mode: :html,
                     chat_id: c.telegram_id }
      SendPayloadWorker.perform_async(:send_message, parameters)
    end
  end
end
