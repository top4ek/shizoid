# frozen_string_literal: true

FactoryBot.define do
  factory :participation, class: Participation do
    user
    chat
    active_at  { Time.current }
    left       { false }
    score      { Random.rand(999) }
    experience { Random.rand(999) }
  end
end
