# frozen_string_literal: true

FactoryBot.define do
  factory :pair do
    first  { association :word }
    second { association :word }
    chat

    trait :begining do
      first { nil }
    end

    trait :ending do
      second { nil }
    end

    trait :data_bank do
      data_bank
      chat { nil }
    end
  end
end
