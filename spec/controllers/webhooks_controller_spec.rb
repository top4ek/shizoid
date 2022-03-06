# frozen_string_literal: true

require 'spec_helper'

describe WebhooksController, type: :controller do
  let(:payload) { hashify_tg build :tg_message }
  let(:token)   { Rails.application.secrets[:telegram][:token].split(':').last }

  it 'ping response' do
    get :ping, as: :json
    expect(response).to have_http_status :ok
  end

  describe 'Token' do
    it 'wrong' do
      body = payload.merge(id: FFaker::Telegram.bot_token)
      post :update, params: body, as: :json
      expect(response).to have_http_status :not_found
    end

    it 'empty' do
      body = payload.merge(id: '')
      post :update, params: body, as: :json
      expect(response).to have_http_status :not_found
    end

    it 'correct' do
      expect(UpdateWorker).to receive_message_chain(:perform_async)
      body = payload.merge(id: token)
      post :update, params: body, as: :json
      expect(response).to have_http_status :ok
    end
  end

  it 'empty body' do
    post :update, params: { id: token }, as: :json
    expect(response).to have_http_status :ok
  end
end
