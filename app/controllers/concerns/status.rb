module Status
  def status(*)
    return unless can_reply?
    respond_with :message, parse_mode: :markdown,
                         text: t('.reply',
                                 active: t("#{@chat.active?}"),
                                 current_locale: t('.locale'),
                                 locales: I18n.available_locales.to_sentence,
                                 gab: @chat.random,
                                 pairs: @chat.pairs.size,
                                 databanks: t("#{@chat.data_bank_ids.present?}"),
                                 singles: @chat.singles.size,
                                 auto_eightball: t("#{@chat.eightball?}"),
                                 winner: @chat.winner || t('.winner.disabled'),
                                 check_bayan: t("#{@chat.bayan?}")
                               )
  end
end
