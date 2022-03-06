# frozen_string_literal: true

Rails.application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
# config.i18n.available_locales = %i[ru_RU en_US]
Rails.application.config.i18n.available_locales = %i[ru_RU]
Rails.application.config.i18n.default_locale = :ru_RU
