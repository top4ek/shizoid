module Bot

  def self.logger
    @logger ||= Log.new
  end

  class Log
    def initialize
      @logger ||= Logger.new(STDERR)
      @logger.info 'Logger started'
    end

    def info(message)
      @logger.info message
    end

    def warn(message)
      @logger.warn message
    end

    def error(message)
      @logger.error message
    end

    def debug(message)
      @logger.debug message
    end

  end

end
