# frozen_string_literal: true

FactoryBot.define do
  factory :single do
    chat
    word
    reply_type { Single.reply_types.keys.sample }
    count      { Random.rand(10) }
    reply      { SecureRandom.hex(32) }
  end
end
