# frozen_string_literal: true

FactoryBot.define do
  factory :tg_chat, class: Telegram::Bot::Types::Chat do
    id                  { FFaker::Telegram.user_id }
    type                { %w[private group supergroup channel].sample }
    title               { FFaker::Job.title }
    username            { FFaker::Internet.user_name }
    first_name          { FFaker::Name.first_name }
    last_name           { FFaker::Name.last_name }
    photo               { association :tg_chat_photo }
    description         { nil }
    invite_link         { nil }
    pinned_message      { nil }
    # permissions         { nil }
    # sticker_set_name    { nil }
    # can_set_sticker_set { nil }
  end
end
