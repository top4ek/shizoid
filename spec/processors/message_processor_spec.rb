# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor, type: :processor do
  subject(:call_result) { described_class.call(message) }

  let(:message) { FactoryBot.build :tg_message }

  let(:available_processors) do
    %w[Me
       Say
       BinaryDice
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
  end

  # describe 'all processors being' do
  #   let(:klasses) do
  #     MessageProcessor::AVAILABLE_PROCESSORS.map do |p|
  #       "MessageProcessor::#{p}".constantize
  #     end
  #   end

  #   it 'initialized' do
  #     klasses.each{ |k| allow(k).to receive(:new) }
  #     call_result
  #     klasses.each { |k| expect(k).to have_received(:new).once }
  #   end

  #   it 'processed' do
  #     klasses.each { |k| allow(k).to receive(:process) }
  #     call_result
  #     klasses.each { |k| expect(k).to have_received(:process).once }
  #   end
  # end

  describe 'AVAILABLE_PROCESSORS' do
    it 'has constant' do
      expect(MessageProcessor::AVAILABLE_PROCESSORS).to eq available_processors
    end

    it 'has source code' do
      files_list = (Dir.entries('app/processors/message_processor/') - %w[. .. base_processor.rb])
      files_list.map! { |m| m.chomp('.rb') }
      blocks_list = MessageProcessor::AVAILABLE_PROCESSORS.map { |b| b.demodulize.underscore }
      expect(files_list).to match_array blocks_list
    end
  end
end
