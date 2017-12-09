FactoryBot.define do
  # include Telegram::Bot::UpdatesController::TypedUpdate
  #TODO Virtus model LEARN

  factory :payload_from, class: Hash do
    id                12345678
    first_name        'Doctor'
    last_name         'Who'
    username          'name'
    language_code     'ru'

    initialize_with   { attributes }
  end

  factory :payload_chat, class: Hash do
    id                12345678
    type              'private'
    title             nil
    first_name        'Doctor'
    last_name         'Who'
    username          'name'

    initialize_with   { attributes }
  end

  factory :payload, class: Hash do
    update_id         123456789
    message           { FactoryBot.build :payload_message }

    initialize_with   { attributes }
  end

  factory :payload_message, class: Hash do
    text              'Привет!'
    message_id        1234
    from              { FactoryBot.build :payload_from }
    chat              { FactoryBot.build :payload_chat }
    date              1504250250
    entities          { [] }
    photo             { [] }
    new_chat_members  { [] }
    new_chat_photo    { [] }

    initialize_with   { attributes }
  end
end
