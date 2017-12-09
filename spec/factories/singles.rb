FactoryBot.define do
  factory :single do
    chat
    word
    reply_type { 0 }
    reply      { FFaker::Lorem.sentence }
    count      1
  end
end
