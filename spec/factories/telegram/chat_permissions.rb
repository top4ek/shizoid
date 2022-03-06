# frozen_string_literal: true

FactoryBot.define do
  factory :tg_chat_permissions, class: 'Telegram::Bot::Types::ChatPermissions' do
    can_send_messages         { true }
    can_send_media_messages   { true }
    can_send_polls            { true }
    can_send_other_messages   { true }
    can_add_web_page_previews { true }
    can_change_info           { false }
    can_invite_users          { true }
    can_pin_messages          { false }
  end
end
