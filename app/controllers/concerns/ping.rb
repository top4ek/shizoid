module Ping
  def ping(*)
    respond_with :message, text: t('.ping').sample if can_reply?
  end
end
