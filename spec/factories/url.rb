# frozen_string_literal: true

FactoryBot.define do
  factory :url do
    url { FFaker::Image.url }
  end
end
