# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: User do
    first_name    { FFaker::Name.first_name }
    last_name     { FFaker::Name.last_name }
    username      { FFaker::Internet.user_name }

    trait :bot_owner do
      id { Rails.application.secrets[:telegram][:owners].sample.to_i }
    end
  end
end
