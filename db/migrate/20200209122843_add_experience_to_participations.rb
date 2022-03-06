# frozen_string_literal: true

class AddExperienceToParticipations < ActiveRecord::Migration[6.0]
  def change
    add_column :participations, :experience, :integer, null: false, default: 0
  end
end
