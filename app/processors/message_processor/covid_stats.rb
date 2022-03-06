# frozen_string_literal: true

module MessageProcessor
  class CovidStats
    include Processor
    include CommandParameters

    def responds?
      super && command == 'covid_stats'
    end

    def process!
      response = case first_parameter
                 when 'enable', 'on'
                   enable
                 when 'disable', 'off'
                   disable
                 when 'available'
                   available_regions
                 else
                   show
                 end

      { send_message: { chat_id: chat.telegram_id,
                        reply_to_message_id: message.message_id,
                        parse_mode: :html,
                        text: response } }
    end

    private

    def available_regions
      list = I18n.t('covid_stat.regions').map do |key, name|
        I18n.t('covid_stat.region_item_html', key: key.to_s.rjust(4), name: name)
      end
      I18n.t('covid_stat.region_list_html', items: list.join("\n"))
    end

    def show
      region = (first_parameter || chat.covid_region || 'ALL').to_s.upcase
      return nok unless region.in? CovidStat.regions.keys

      CovidStat.day_stats(region: region, return_i18n: true)
    end

    def enable
      param = second_parameter.to_s.upcase
      param = 'ALL' if param.blank?
      return nok unless param.in? CovidStat.regions.keys

      chat.update!(covid_region: param)
      ok
    end

    def disable
      chat.update!(covid_region: nil)
      ok
    end
  end
end
