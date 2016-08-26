module Bot

  def self.logger
    @logger ||= Log.new Bot.configuration.debug_level
  end

  class Log

    def initialize(debug_level)
      @logger ||= Logger.new(STDERR)
      @logger.info 'Logger started'
      @debug_level = debug_level
    end

    def info(message)
      @logger.info truncate(message) if [:info, :debug].include? @debug_level.to_sym
    end

    def warn(message)
      @logger.warn truncate(message) if [:debug].include? @debug_level.to_sym
    end

    def error(message)
      @logger.error truncate(message) if [:info, :debug].include? @debug_level.to_sym
    end

    def debug(message)
      @logger.debug truncate(message) if [:debug].include? @debug_level.to_sym
    end

    private

    def truncate(text)
      if text
        text.size > 250 ? "#{text[0..250]}…" : text
      end
    end
  end

end
