# frozen_string_literal: true

FactoryBot.define do
  factory :chat, class: Chat do
    kind            { %w[private group supergroup channel].sample }
    random          { rand 50 }
    bayan           { [true, false].sample }
    eightball       { [true, false].sample }
    greeting        { [true, false].sample }
    winner          { FFaker::Name.first_name }
    locale          { 'ru' }
    first_name      { FFaker::Name.first_name }
    last_name       { FFaker::Name.last_name }
    username        { FFaker::Internet.user_name }
    telegram_id     { FFaker::Telegram.user_id }
    active_at       { 10.minutes.ago }
    title           { FFaker::Job.title }
    data_bank_ids   { [] }

    trait :disabled_random do
      random { 100 }
    end

    trait :disabled do
      active_at { nil }
    end
  end
end
