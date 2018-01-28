class ShizoidController < Telegram::Bot::UpdatesController
  include Telegram::Bot::Botan::ControllerHelpers
  include Telegram::Bot::UpdatesController::TypedUpdate
  include HelperMethods
  include Eightball
  include Databanks
  include Gab
  include Status
  include CoolStory
  include Locale
  include Help
  include Me
  include Ids
  include Ping
  include WinnerOfTheDay
  include Bayanizator
  # include Greeting

  before_action :fetch_data
  after_action :learn

  def start(*args)
    return respond_with :message, text: nok unless admin?
    @chat.update(active: true)
    respond_with :message, text: ok
  end

  def stop(*)
    return reply_with :message, text: nok unless admin?
    begin
      bot.async(false) do
        respond_with :message, text: ok
        bot.leave_chat chat_id: @chat.telegram_id unless @chat.personal?
      end
    rescue
      NewRelic::Agent.notice_error('Forbidden', custom_params: { chat: @chat.id })
    end
    ChatDestroyer.perform_async(@chat.id)
  end

  def message(*text)
    return unless can_reply? && !payload.from.is_bot
    if @chat.winner.present?
      count = 1
      count = @words.uniq.size if @words.present? && @words.size > 1
      StatsUpdater.perform_async({ id: @chat.id, from: from.id, count: count })
      winner(text) unless Winner.gambled?(@chat.id)
    end
    return reply_with(:message, text: t('.bayan').sample) if bayan?
    return eightball(text) if question? && @chat.eightball?
    return unless anchors? || reply_to_bot? || @chat.random_answer? || @chat.personal?
    if text? && !command?
      return reply_single if @words.size == 1
      send_typing_action
      reply = @chat.generate(@words)
      respond_with :message, text: reply if reply.present?
    end
  end

  private

  def fetch_user_info(chat_id, user_id)
    begin
      result = bot.async(false) { bot.get_chat_member(chat_id: chat_id, user_id: user_id) }
    rescue
      result = nil
    end
    unless result.present? && result['ok'] && result['result']['user'].present?
      NewRelic::Agent.notice_error('UserNotFetched', custom_params: { chat: chat_id, user: user_id, result: result })
      return nil
    end
    user_data = result['result']['user']
    user = Chat.find_by(telegram_id: user_id) || Chat.create(telegram_id: user_id, kind: :personal)
    options = { id: user_id, title: nil, kind: 'private', first_name: user_data['first_name'],
                last_name: user_data['last_name'], username: user_data['username'] }
    ChatUpdater.perform_async(options)
    "#{user_data['username'] || user_data['first_name'] || user_data['last_name']}"
  end

  def reply_single
    reply = Single.answer(@chat.id, @words.first)
    return unless reply.present?
    case reply.reply_type
    when 'text'
      respond_with :message, text: reply.reply
      send_typing_action
      words = Word.to_ids(reply.reply.downcase.split(' ').uniq)
      text_reply = @chat.generate(words)
      respond_with :message, text: text_reply if text_reply.present?
    when 'sticker'
      respond_with :sticker, sticker: reply.reply
    when 'document'
      respond_with :document, document: reply.reply
    end
  end

  def fetch_data
    @chat = Chat.learn payload
    @chat.update(active: false) if payload&.left_chat_member&.id == bot_id
    I18n.locale = @chat.locale
    if text?
      text = payload.text.downcase.dup
      payload.entities.each do |entity|
        if entity.offset+entity.length > text.size
          NewRelic::Agent.notice_error('PayloadShort', custom_params: { chat: @chat.id, payload: payload })
          next
        end
        text[entity.offset, entity.length] = ' ' * entity.length unless entity.type == 'bold'
      end
      @words = text.split(' ')
      @text = @words.join(' ')
    end
  end

  def learn
    if @chat.active? && !payload.from.is_bot && !command? && !(@chat.eightball? && question?)
      if text? && @words.size > 1
        options = { id: @chat.id, words: @words }
        PairUpdater.perform_async(options)
        ContextUpdater.perform_async(options)
      end
      Single.learn(@chat.id, payload) if reply?
    end
  end
end
