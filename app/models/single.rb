class Single < ApplicationRecord
  belongs_to :word
  belongs_to :chat

  enum reply_type: %i[sticker document text]

  class << self

    def answer(chat_id, word)
      word = Word.find_by(word: word)
      return nil unless word.present?
      word.singles.where(chat_id: chat_id).order(count: :desc).sample
    end

    def learn(chat_id, payload)
      key = payload.reply_to_message&.text&.split(' ')
      answer = [ payload.text, payload.sticker, payload.document ]
      return nil unless key.present? && key.size == 1 && answer.any?
      key = key.first.downcase
      Word.learn([key])
      if !!payload.text
        text = remove_entities(payload)
        reply = { type: :text, data: text} if text.present?
      end
      reply = { type: :document, data: payload.document.file_id} if !!payload.document
      reply = { type: :sticker, data: payload.sticker.file_id} if !!payload.sticker
      if reply.present?
        Single.find_or_create_by(word_id: Word.find_by(word: key).id,
                                 chat_id: chat_id,
                                 reply_type: reply[:type],
                                 reply: reply[:data]).increment! :count
      end
    end

    private

    def remove_entities(message)
      text = message.text.downcase.dup
      message.entities.each do |entity|
        if entity.offset+entity.length > text.size
          NewRelic::Agent.notice_error('PayloadShort', custom_params: { message: message })
          next
        end
        text[entity.offset, entity.length] = ' ' * entity.length unless entity.type == 'bold'
      end
      text.split(' ').join(' ')
    end
  end
end
