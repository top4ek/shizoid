FactoryBot.define do
  factory :greeting do
    chat
    text { FFaker::Lorem.sentence }
  end
end
