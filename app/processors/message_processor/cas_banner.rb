# frozen_string_literal: true

module MessageProcessor
  class CasBanner
    include Processor
    include CommandParameters

    def responds?
      super && command == 'cas'
    end

    def process!
      response = case first_parameter
                 when 'enable', 'on'
                   enable
                 when 'disable', 'off'
                   disable
                 else
                   show
                 end

      { send_message: { chat_id: chat.telegram_id,
                        reply_to_message_id: message.message_id,
                        parse_mode: :markdown,
                        text: response } }
    end

    private

    def enable
      chat.update!(casbanhammer_at: Time.current)
      ok
    end

    def disable
      chat.update!(casbanhammer_at: nil)
      ok
    end

    def show
      I18n.t('.cas_banner', active: I18n.t(chat.casbanhammer?.to_s),
                            count: chat.participations.joins(:user).where.not(users: { casbanned_at: nil }).size,
                            overall: User.casbanned.size)
    end

    def background_task
      user.update_casban

      new_chat_members.map { |m| User.learn(m).update_casban } if new_chat_members.present?

      Participation.ban_all
    end
  end
end
