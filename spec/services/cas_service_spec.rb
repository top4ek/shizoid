# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasService do
  subject(:call_method) { described_class.banned?(user.id) }

  let(:stub) { webmocks(:cas, :check, telegram_id: user.id, banned: user.casbanned?) }

  before { stub }

  shared_examples 'status checker' do
    it do
      expect(call_method).to eq user.casbanned?
    end

    it 'makes request' do
      call_method
      expect(stub[:mock]).to have_been_requested
    end
  end

  describe 'banned' do
    let(:user) { create :user, :casbanned }

    it_behaves_like 'status checker'
  end

  describe 'not banned' do
    let(:user) { create :user }

    it_behaves_like 'status checker'
  end
end
