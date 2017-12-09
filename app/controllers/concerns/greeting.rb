module Greeting
  def greeting(*args)
    return unless can_reply?
    # reply_text = t('.status.locale')
    case args.first
    when '—add', '--add'
    when '—delete', '--delete'
    when '—clear', '--clear'
    when '—list', '--list'
    when '—show', '--show'
    else

    end
    respond_with :message, text: reply_text
    return unless can_reply?
    respond_with :message, text: nok
  end
end
