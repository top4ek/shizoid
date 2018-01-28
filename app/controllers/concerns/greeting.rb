module Greeting
  def greeting(*args)
    return unless can_reply?
    # reply_text = t('.status.locale')
    case args.first
    when 'add'
    when 'delete'
    when 'clear'
    when 'list'
    when 'show'
    else

    end
    respond_with :message, text: reply_text
    return unless can_reply?
    respond_with :message, text: nok
  end
end
