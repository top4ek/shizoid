FactoryBot.define do
  factory :word, aliases: [:first, :second] do
    word { FFaker::Lorem.word }
  end
end
