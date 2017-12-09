module Shizoid
  module Redis
    def self.connection
      @connection ||= ::Redis.new(url: Rails.application.secrets.redis)
    end
  end
end
