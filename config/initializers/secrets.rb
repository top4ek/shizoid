# frozen_string_literal: true

Rails.application.configure do
  config.secrets = config_for(:secrets).deep_symbolize_keys
end
