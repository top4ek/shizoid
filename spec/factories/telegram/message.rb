# frozen_string_literal: true

FactoryBot.define do
  factory :tg_message, class: 'Telegram::Bot::Types::Message' do
    message_id              { rand(10_000_000) }
    from                    { association :tg_user }
    date                    { Time.current.to_i }
    chat                    { association :tg_chat }
    text                    { FFaker::Lorem.sentence }
    forward_from            { nil }
    forward_from_chat       { nil }
    forward_from_message_id { nil }
    forward_signature       { nil }
    # forward_sender_name     { nil }
    forward_date            { nil }
    reply_to_message        { nil }
    edit_date               { nil }
    # media_group_id          { nil }
    author_signature        { nil }
    entities                { nil }
    # caption_entities        { nil }
    audio                   { nil }
    document                { nil }
    # animation               { nil }
    game                    { nil }
    photo                   { nil }
    sticker                 { nil }
    video                   { nil }
    voice                   { nil }
    video_note              { nil }
    caption                 { nil }
    contact                 { nil }
    location                { nil }
    venue                   { nil }
    # poll                    { nil }
    new_chat_members        { nil }
    left_chat_member        { nil }
    new_chat_title          { nil }
    new_chat_photo          { nil }
    delete_chat_photo       { nil }
    group_chat_created      { nil }
    supergroup_chat_created { nil }
    channel_chat_created    { nil }
    migrate_to_chat_id      { nil }
    migrate_from_chat_id    { nil }
    pinned_message          { nil }
    invoice                 { nil }
    successful_payment      { nil }
    # connected_website       { nil }
    # passport_data           { nil }
    # reply_markup            { nil }

    trait :picture do
      text { nil }
    end

    trait :reply do
      reply_to_message { association :tg_message }
    end

    trait :from_bot_owner do
      from { association :tg_user, :bot_owner }
    end

    trait :command_databank_enable do
      text     { "/databank enable" }
      entities { [{ type: 'bot_command', offset: 0, length: 9 }] }
    end

    trait :command_databank_disable do
      text     { '/databank disable' }
      entities { [{ type: 'bot_command', offset: 0, length: 9 }] }
    end

    trait :command_databank do
      text     { '/databank' }
      entities { [{ type: 'bot_command', offset: 0, length: 9 }] }
    end

    trait :command_covid_stats_enable do
      text     { "/covid_stats enable #{CovidStat.regions.keys.sample}" }
      entities { [{ type: 'bot_command', offset: 0, length: 12 }] }
    end

    trait :command_covid_stats_disable do
      text     { '/covid_stats disable' }
      entities { [{ type: 'bot_command', offset: 0, length: 12 }] }
    end

    trait :command_covid_stats_available do
      text     { '/covid_stats available' }
      entities { [{ type: 'bot_command', offset: 0, length: 12 }] }
    end

    trait :command_covid_stats do
      text     { '/covid_stats' }
      entities { [{ type: 'bot_command', offset: 0, length: 12 }] }
    end

    trait :command_winner_enable do
      text     { "/winner enable #{FFaker::Lorem.word}" }
      entities { [{ type: 'bot_command', offset: 0, length: 7 }] }
    end

    trait :command_winner_disable do
      text     { '/winner disable' }
      entities { [{ type: 'bot_command', offset: 0, length: 7 }] }
    end

    trait :command_winner_current do
      text     { '/winner current' }
      entities { [{ type: 'bot_command', offset: 0, length: 7 }] }
    end

    trait :command_winner do
      text     { '/winner' }
      entities { [{ type: 'bot_command', offset: 0, length: 7 }] }
    end

    trait :command_me do
      text     { "/me #{FFaker::Lorem.sentence}" }
      entities { [{ type: 'bot_command', offset: 0, length: 3 }] }
    end

    trait :command_me_username do
      text     { "/me@Shizoid_bot #{FFaker::Lorem.sentence}" }
      entities { [{ type: 'bot_command', offset: 0, length: 3 }] }
    end

    trait :command_empty_me do
      text     { '/me ' }
      entities { [{ type: 'bot_command', offset: 0, length: 3 }] }
    end

    trait :command_start do
      text     { '/start' }
      entities { [{ type: 'bot_command', offset: 0, length: 5 }] }
    end

    trait :command_stop do
      text     { '/stop' }
      entities { [{ type: 'bot_command', offset: 0, length: 4 }] }
    end

    trait :command_say do
      text     { "/say #{FFaker::Lorem.sentence}" }
      entities { [{ type: 'bot_command', offset: 0, length: 4 }] }
    end

    trait :command_ids do
      text     { '/ids' }
      entities { [{ type: 'bot_command', offset: 0, length: 4 }] }
    end

    trait :command_empty_gab do
      text     { '/gab' }
      entities { [{ type: 'bot_command', offset: 0, length: 4 }] }
    end

    trait :command_ping do
      text     { '/ping' }
      entities { [{ type: 'bot_command', offset: 0, length: 5 }] }
    end

    trait :command_cool_story do
      text     { '/cool_story' }
      entities { [{ type: 'bot_command', offset: 0, length: 11 }] }
    end

    trait :command_status do
      text     { '/status' }
      entities { [{ type: 'bot_command', offset: 0, length: 7 }] }
    end

    trait :command_help do
      text     { '/help' }
      entities { [{ type: 'bot_command', offset: 0, length: 5 }] }
    end

    trait :command_eightball do
      text     { "/eightball #{FFaker::Lorem.sentence}" }
      entities { [{ type: 'bot_command', offset: 0, length: 10 }] }
    end

    trait :command_empty_eightball do
      text     { "/eightball" }
      entities { [{ type: 'bot_command', offset: 0, length: 10 }] }
    end

    trait :with_migration do
      migrate_from_chat_id { chat.id }
      migrate_to_chat_id   { FFaker::Telegram.user_id }
    end

    trait :new_chat_members do
      new_chat_members { Array.new(2) { association :tg_user } }
    end

    trait :command_cas_enable do
      text     { "/cas enable #{CovidStat.regions.keys.sample}" }
      entities { [{ type: 'bot_command', offset: 0, length: 4 }] }
    end

    trait :command_cas_disable do
      text     { '/cas disable' }
      entities { [{ type: 'bot_command', offset: 0, length: 4 }] }
    end

    trait :command_cas do
      text     { '/cas' }
      entities { [{ type: 'bot_command', offset: 0, length: 4 }] }
    end

  end
end
