# frozen_string_literal: true

module RedisService
  class << self
    def connection
      @connection ||= Redis.new(Rails.configuration.secrets[:cache_redis])
    end

    delegate :multi, :lrange, :set, :get, :incr, :decr, to: :connection
  end
end
