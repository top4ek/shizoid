class Reply < ActiveRecord::Base
  belongs_to :pairs
  belongs_to :word
end
