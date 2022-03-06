# frozen_string_literal: true

class WebhooksController < ActionController::API
  def update
    render result
  end

  def ping
    render status: :ok, json: 'ok'
  end

  private

  def result
    return { status: :not_found } unless token_valid?

    UpdateWorker.perform_async request_params
    { status: :ok, json: {} }
  end

  def request_params
    params.permit!.to_h # (:update_id, message: {})
  end

  def token_valid?
    params[:id] == TelegramService.token_secret
  end
end
