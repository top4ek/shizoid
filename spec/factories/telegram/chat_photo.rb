# frozen_string_literal: true

FactoryBot.define do
  factory :tg_chat_photo, class: Telegram::Bot::Types::ChatPhoto do
    small_file_id { nil }
    big_file_id   { nil }
  end
end
