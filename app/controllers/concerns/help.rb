module Help
  def help(*)
    respond_with :message, text: t('.help'), parse_mode: :markdown
  end
end
