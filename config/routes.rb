# frozen_string_literal: true

Rails.application.routes.draw do
  get :ping, to: 'webhooks#ping'
  post '/:id', to: 'webhooks#update'
end
