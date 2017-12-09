class RemoveOneWorldSentences < ActiveRecord::Migration[5.1]
  def change
    Reply.joins(:pair).where(word_id: nil, pairs: { first_id: nil }).destroy_all
    Pair.includes(:replies).where(first_id: nil, replies: { id: nil } ).destroy_all
  end
end
