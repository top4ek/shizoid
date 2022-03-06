# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:tg_user) { build :tg_user }
  let(:user)     { create :user, id: tg_user.id }
  let(:message)  { build :tg_message, from: tg_user }

  it { should have_many(:chats).through(:participations) }

  it 'has valid factory' do
    expect(user).to be_valid
  end

  describe 'learn' do
    it 'creates user' do
      expect { described_class.learn(message) }
        .to change(described_class, :count).by(1)
    end

    it '#to_s returns name as string' do
      name = user.username || user.first_name || user.last_name
      expect(user.to_s).to eq name
    end

    it '#to_link returns name as html' do
      link = "<a href='tg://user?id=#{user.id}'>#{user}</a>"
      expect(user.to_link).to eq link
    end

    it 'updates data' do
      user
      expect { described_class.learn(message) }
        .not_to change(described_class, :count)
      user.reload
      %i[username first_name last_name].each do |f|
        expect(user.send(f)).to eq message.from.send(f)
      end
    end
  end
end
