FactoryBot.define do
  factory :winner do
    chat
    user_id     { 123 }
    created_at  { Date.today }

    trait :two_years_ago do
      created_at  { 2.years.ago }
    end

    trait :yesterday do
      created_at  { Date.yesterday }
    end

    factory :old_winner, traits: [:two_years_ago]
    factory :yesterday_winner, traits: [:yesterday]
  end
end
