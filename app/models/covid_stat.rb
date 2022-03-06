# frozen_string_literal: true

class CovidStat < ApplicationRecord
  enum region: {
    ALL: 0,
    AD: 2, ALT: 3, AMU: 4, ARK: 5, AST: 6, BA: 7, BEL: 8, BRY: 9, BU: 10, CE: 11, CHE: 12, CHU: 13, CR: 14, CU: 15, DA: 16,
    GA: 17, IN: 18, IRK: 19, IVA: 20, KAM: 21, KB: 22, KC: 23, KDA: 24, KEM: 25, KGD: 26, KGN: 27, KHA: 28, KHM: 29, KIR: 30,
    KK: 31, KL: 32, KLU: 33, KO: 34, KOS: 35, KR: 36, KRS: 37, KYA: 38, LEN: 39, LIP: 40, MAG: 41, ME: 42, MO: 43, MOS: 44,
    MOW: 45, MUR: 46, NEN: 47, NGR: 48, NIZ: 49, NVS: 50, OMS: 51, ORE: 52, ORL: 53, PER: 54, PNZ: 55, PRI: 56, PSK: 57,
    ROS: 58, RYA: 59, SA: 60, SAK: 61, SAM: 62, SAR: 63, SE: 64, SMO: 65, SPE: 66, STA: 67, SVE: 68, TAM: 69, TOM: 70, TT: 71,
    TUL: 72, TVE: 73, TY: 74, TYU: 75, UD: 76, ULY: 77, VGG: 78, VLA: 79, VLG: 80, VOR: 81, YAN: 82, YAR: 83, YEV: 84, ZAB: 85
  }

  VIRTUAL_REGIONS = ['ALL'].freeze
  FETCHABLE_REGIONS = (regions.keys - VIRTUAL_REGIONS).freeze
  STATISTICS_ATTRIBUTES = %i[sick healed died].freeze

  validates :region, inclusion: { in: FETCHABLE_REGIONS }

  class << self
    def day_stats(region: 'ALL', date: nil, return_i18n: false)
      date ||= CovidStat.order(date: :desc).first.date

      select_params = STATISTICS_ATTRIBUTES.map { |a| "SUM(#{a}) as #{a}" }.join(',')
      current_stats, previous_stats = [date, date - 1.day].map do |d|
        query = { date: d }
        query[:region] = region if region != 'ALL'
        CovidStat.where(query).select(select_params)
      end.flatten

      results = { date: date, region: region, current: current_stats }
      results[:delta] = STATISTICS_ATTRIBUTES.map do |a|
        previous_param = previous_stats.send(a)
        current_param = current_stats.send(a)

        result = if current_param.nil? || previous_param.nil?
                   '?'
                 else
                   current_param - previous_param
                 end
        [a, result]
      end.to_h
      if return_i18n
        printable_results = STATISTICS_ATTRIBUTES.map do |a|
          current = results[:current].send(a) || '?'
          delta = results[:delta][a]
          delta = if delta.present?
                    delta.to_i.positive? ? "+#{delta}" : delta.to_s
                  else
                    '?'
                  end
          [a, "#{current} (#{delta})"]
        end.to_h

        I18n.t('covid_stat.stats_html', region: I18n.t("covid_stat.regions.#{region}"),
                                        date: date,
                                        sick: printable_results[:sick],
                                        healed: printable_results[:healed],
                                        died: printable_results[:died])
      else
        results
      end
    end

    def needs_update?
      sample_region = FETCHABLE_REGIONS.sample
      remote_max_date = StopCovidService.get_data(sample_region).map { |r| r[:date] }.max
      local_max_date = CovidStat.where(region: sample_region).maximum(:date)
      return true if local_max_date.blank?

      remote_max_date > local_max_date
    end

    def update_all
      FETCHABLE_REGIONS.each { |r| CovidRegionUpdaterWorker.perform_async(r) }
    end

    def update(region_id)
      StopCovidService.get_data(region_id).map do |r|
        record_key = { date: r[:date], region: region_id }
        stat_record = CovidStat.find_or_initialize_by(record_key)
        stat_record.update(r.except(:date, :region))
        stat_record.save!
        stat_record
      end
    end
  end
end
