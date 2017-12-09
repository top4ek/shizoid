FactoryBot.define do
  factory :url do
    url       { FFaker::Internet.uri :http }
  end
end
