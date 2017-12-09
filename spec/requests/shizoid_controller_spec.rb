# require 'rails_helper'
require 'telegram/bot/rspec/integration'
# require 'telegram/bot/updates_controller/rspec_helpers'

# RSpec.describe ShizoidController, :telegram_bot do
#   describe '#start' do
#     let!(:chat) { FactoryBot.create :chat }
#     let(:chat_id) { chat.id }
#     let(:payload) { FactoryBot.build :payload_message }

#     subject { -> { dispatch_message '/start', payload } }
#     it 'parses payload' do
#       chat.active = true
#       # request = dispatch_message '/start', payload
#       # expect { request }.to respond_with_message 'asd'
#       expect_to respond_with_message 'Hi there!'
#     end
#     # it { should.not_to respond_with_message 'Hi there!' }
#   end
# end
