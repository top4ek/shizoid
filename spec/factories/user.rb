# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: User do
    first_name       { FFaker::Name.first_name }
    last_name        { FFaker::Name.last_name }
    username         { FFaker::Internet.user_name }
    casbanned_at     { nil }
    casbanchecked_at { 1.minute.ago }

    trait :bot_owner do
      id { Rails.application.secrets[:telegram][:owners].sample.to_i }
    end

    trait :casbanned do
      casbanned_at { 1.day.ago.round }
    end
  end
end
