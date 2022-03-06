# frozen_string_literal: true

FactoryBot.define do
  factory :winner do
    chat
    user
    sequence(:date) { FFaker::Time.date }
  end
end
