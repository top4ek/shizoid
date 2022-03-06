# frozen_string_literal: true

FactoryBot.define do
  factory :tg_user, class: Telegram::Bot::Types::User do
    id            { FFaker::Telegram.user_id }
    is_bot        { false }
    first_name    { FFaker::Name.first_name }
    last_name     { FFaker::Name.last_name }
    username      { FFaker::Internet.user_name }
    language_code { nil }

    trait :bot_owner do
      id { Rails.application.secrets[:telegram][:owners].sample.to_i }
    end
  end
end
