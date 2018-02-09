module Status
  def status(*)
    return unless can_reply?
    respond_with :message, parse_mode: :markdown,
                           text: t('.reply',
                                   active: t(@chat.enabled?.to_s),
                                   gab: @chat.random,
                                   pairs: @chat.pairs.size,
                                   databanks: t(@chat.data_bank_ids.present?.to_s),
                                   singles: @chat.singles.size,
                                   auto_eightball: t(@chat.eightball?.to_s),
                                   winner: @chat.winner || t('.winner.disabled'),
                                   check_bayan: t(@chat.bayan?.to_s))
  end
end
