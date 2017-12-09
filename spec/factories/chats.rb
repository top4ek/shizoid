FactoryBot.define do
  factory :chat do
    telegram_id { rand(1000000) }
    kind        0
    active      false
    random      0
    bayan       false
    eightball   false
    greeting    false
    winner      nil
    locale      'ru'
    title       FFaker::Lorem.sentence
    first_name  FFaker::NameRU.first_name
    last_name   FFaker::NameRU.last_name
    username    FFaker::Internet.user_name

    trait :disabled do
      active false
    end

    trait :private do
      title nil
      kind 0
    end

    trait :groupchat do
      first_name nil
      last_name nil
      kind 2
    end

    factory :disabled_chat, traits: [:disabled]
    factory :group_chat, traits: [:groupchat]
    factory :private_chat, traits: [:private]
  end
end
