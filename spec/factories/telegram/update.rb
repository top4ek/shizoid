# frozen_string_literal: true

FactoryBot.define do
  factory :tg_update, class: Telegram::Bot::Types::Update do
    update_id { rand(10_000_000) }
    message   { association :tg_message }
    # edited_message
    # channel_post
    # edited_channel_post
    # inline_query
    # chosen_inline_result
    # callback_query
    # shipping_query
    # pre_checkout_query
    # poll
    trait :without_message do
      message { nil }
    end
  end
end
