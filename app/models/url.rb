class Url < ApplicationRecord
  def self.seen?(url)
    return true if Url.exists? url: url
    Url.create url: url
    false
  end
end
