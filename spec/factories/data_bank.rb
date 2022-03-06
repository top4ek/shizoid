# frozen_string_literal: true

FactoryBot.define do
  factory :data_bank do
    name { FFaker::Lorem.sentence }
  end
end
