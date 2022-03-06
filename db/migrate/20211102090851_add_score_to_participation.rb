class AddScoreToParticipation < ActiveRecord::Migration[6.1]
  def change
    add_column :participations, :score, :integer, null: false, default: 0
    add_index :participations, %i[chat_id user_id], unique: true
  end
end
