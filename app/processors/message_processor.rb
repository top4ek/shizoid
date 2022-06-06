# frozen_string_literal: true

module MessageProcessor
  AVAILABLE_PROCESSORS = %w[CasBanner
                            Me
                            Say
                            BinaryDice
                            CovidStats
                            CoolStory
                            Databank
                            Eightball
                            Gab
                            Help
                            Holiday
                            Ids
                            Ping
                            Start
                            Status
                            Stop
                            Winner
                            Text].freeze
  def self.call(message)
    deserialized_message = Telegram::Bot::Types::Message.new(message)
    process_result = nil
    AVAILABLE_PROCESSORS.each do |processor|
      klass = "MessageProcessor::#{processor}".constantize.new(deserialized_message)
      process_result = klass.process if process_result.nil?
    end
    return if process_result.blank?

    process_result.each { |command, parameters| SendPayloadWorker.perform_async(command, parameters) }
  end
end
