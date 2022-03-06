# frozen_string_literal: true

FactoryBot.define do
  factory :word do
    word { FFaker::Lorem.unique.word }
  end
end
