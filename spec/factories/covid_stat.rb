# frozen_string_literal: true

FactoryBot.define do
  factory :covid_stat do
    region { CovidStat::FETCHABLE_REGIONS.sample }
    date   { Time.current.to_date }
    sick   { Random.rand(999) }
    healed { Random.rand(999) }
    died   { Random.rand(999) }
    first  { Random.rand(999) }
    second { Random.rand(999) }
  end
end
