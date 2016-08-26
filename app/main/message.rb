module Bot
  class Message

    EIGHTBALL_ANSWERS = [ 'Бесспорно.',
                          'Предрешено.',
                          'Никаких сомнений.',
                          'Определённо да.',
                          'Можешь быть уверен в этом.',
                          'Мне кажется — «да»',
                          'Вероятнее всего.',
                          'Хорошие перспективы.',
                          'Знаки говорят — «да».',
                          'Да.',
                          'Пока не ясно.',
                          'Cпроси завтра.',
                          'Лучше не рассказывать.',
                          'Сегодня нельзя предсказать.',
                          'Сконцентрируйся и спроси опять.',
                          'Даже не думай.',
                          'Мой ответ — «нет».',
                          'По моим данным — «нет».',
                          'Перспективы не очень хорошие.',
                          'Весьма сомнительно.' ]

    COMMANDS = %i(set_gab get_stats ping eightball get_gab)

    attr_reader :message, :words, :text, :chat

    def initialize(bot, message)
      @bot = bot
      @message = message
      @chat = ::Chat.get_chat @message
      @chat.migrate_to_chat_id @message.migrate_to_chat_id if @message.migrate_to_chat_id.present?
      if has_text?
        @text = @message.text
        @words = get_words
        @command = get_command if @text.chars.first == '/'
      end
    end

    def process
      if has_text? && !is_editing?
        return process_message unless is_command?
        send(@command)
      end
    end

    def is_command?
      @command.present?
    end

    def answer(message)
      @bot.api.send_message(chat_id: @chat.telegram_id, text: message)
    end

    def reply(message)
      @bot.api.send_message(chat_id: @chat.telegram_id, reply_to_message_id: @message.message_id, text: message)
    end

    def has_text?
      @message.text.present?
    end

    def is_editing?
      @message.edit_date.present?
    end

    def has_entites?
      @message.entities.present?
    end

    def private?
      @message.chat.type == 'private'
    end

    def has_anchors?
      has_text? && (Bot.configuration.anchors & @words).any? || (@text.include? Bot.configuration.bot_name)
    end

    def reply_to_bot?
      @message.reply_to_message&.from&.username == Bot.configuration.bot_name
    end

    private

    def random_answer?
      rand(100) < @chat.random_chance
    end

    def process_message
      Pair.learn self
      if has_anchors? || private? || reply_to_bot? || random_answer?
        reply = Pair.generate self
        answer reply if reply.present?
      end
    end

    def set_gab
      percent = @text.split.second.to_i
      return reply "0-50 allowed, Dude!" if percent < 0 || percent > 50
      @chat.update(random_chance: percent)
      reply "Ya wohl, Lord Helmet! Setting gab to #{percent}"
    end

    def get_gab
      reply "Pizdlivost level is on #{@chat.random_chance}"
    end

    def get_stats
      reply "Known pairs in this chat: #{@chat.pairs.size}."
    end

    def ping
      reply "Pong."
    end

    def eightball
      digest = Digest::SHA1.hexdigest(@text).to_i(16) - Date.today.to_time.to_i.div(100) - @message.from.id
      answer_id = digest.divmod(EIGHTBALL_ANSWERS.count)[1]
      reply "#{EIGHTBALL_ANSWERS[answer_id]} #{Pair.generate self}"
    end

    def get_command
      command = @text.split.first[1..-1].split('@').first
      return nil unless command.present?
      command.to_sym if COMMANDS.include? command.to_sym
    end

    def get_words
      text = @text.dup
      @message.entities.each { |entity| text[entity.offset, entity.length] = ' ' * entity.length }
      text.split(' ')
    end

  end
end
