# frozen_string_literal: true

module HashifyTelegramObject
  def hashify_tg(object)
    JSON.parse(object.to_json).with_indifferent_access
  end
end
