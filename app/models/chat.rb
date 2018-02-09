class Chat < ApplicationRecord
  has_many :pairs, dependent: :destroy
  # has_many :greetings, dependent: :destroy
  has_many :singles, dependent: :destroy
  has_many :winners, dependent: :destroy
  has_many :urls

  enum kind: %i[personal faction supergroup channel]

  def to_s
    "#{(username || first_name || last_name || title)}"
  end

  def to_link
    "<a href='tg://user?id=#{telegram_id}'>#{to_s}</a>"
  end

  def enabled?
    !disabled?
  end

  def disabled?
    active_at.nil?
  end

  def enable!
    update(active_at: Time.now)
  end

  def disable!
    update(active_at: nil)
  end

  def random_answer?(additional = 0)
    rand(100) < (random + additional)
  end

  def generate_story
    Pair.generate_story(self)
  end

  def generate(words)
    Pair.generate(chat: self, words: words)
  end

  def context(ids = nil)
    size = Rails.application.secrets.context_size
    current = Shizoid::Redis.connection.lrange(redis_context_path, 0, size).map(&:to_i)
    return current.shuffle if ids.nil?
    uniq_ids = ids.uniq
    current -= uniq_ids
    current.unshift(*uniq_ids)
    Shizoid::Redis.connection.multi do |r|
      r.del(redis_context_path)
      r.lpush(redis_context_path, current.first(size))
    end
  end

  def self.names(ids)
    Chat.where(telegram_id: ids).map { |n| [n.telegram_id, n.to_s] }.to_h
  end

  def self.learn(payload)
    chat = Chat.find_by(telegram_id: payload.chat.id) || Chat.new(telegram_id: payload.chat.id,
                                                                  kind: adopt_type(payload.chat.type))
    chat.telegram_id = payload.migrate_to_chat_id unless payload.migrate_to_chat_id.nil?
    chat.save
    options = { id: chat.id, title: payload.chat.title, first_name: payload.chat.first_name,
                last_name: payload.chat.last_name, username: payload.chat.username, kind: payload.chat.type }
    ChatUpdater.perform_async(options)

    if payload.from.present? && payload.chat.id != payload.from.id
      user = Chat.find_by(telegram_id: payload.from.id) || Chat.create(telegram_id: payload.from.id, kind: :personal)
      options = { id: user.id, title: nil, kind: 'private', first_name: payload.from.first_name,
                  last_name: payload.from.last_name, username: payload.from.username }
      ChatUpdater.perform_async(options)
    end
    chat
  end

  def update_meta(title:, first_name:, last_name:, username:, kind:, members_count: nil)
      self.title          = title                        if self.title != title
      self.first_name     = first_name                   if self.first_name != first_name
      self.last_name      = last_name                    if self.last_name != last_name
      self.username       = username                     if self.username != username
      self.kind           = self.class.adopt_type(kind)  if self.kind != self.class.adopt_type(kind)
      self.members_count  = members_count                if members_count.present? && self.members_count != members_count
      self.active_at      = DateTime.now                 if enabled?
      self.save
  end

  private

  def redis_context_path
    "chat_context/#{id}"
  end

  def self.adopt_type(type)
    case type
    when 'private'
      :personal
    when 'group'
      :faction
    else
      type.to_sym
    end
  end
end
