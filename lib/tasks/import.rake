namespace :import do
  task from_csv: :environment do
    require 'csv'

    words = {}
    counter = 0
    CSV.foreach("db/words.csv") do |row|
      id, word = row
      next if id == 'id'
      downcased = word.downcase
      words[id] = downcased
      counter += 1
      print "Word-#{counter}: #{downcased}                                            \r"
      next if Word.exists?(word: downcased)
      Word.create(word: downcased)
    end

    counter = 0
    puts ''
    CSV.foreach("db/chats.csv") do |row|
      id, type, random, mode, locale, title, first_name, last_name, username = row
      next if id == 'id' || Chat.exists?(id: id.to_i) || (mode != '2')
      new_chat = Chat.new
      new_chat.id = id.to_i
      new_chat.title = title
      new_chat.first_name = first_name
      new_chat.last_name = last_name
      new_chat.username = username
      new_chat.active_at = nil
      new_chat.random = random.to_i
      new_chat.kind = type.to_i
      new_chat.save
      counter += 1
      print "Chat-#{counter}: #{new_chat}                                            \r"
    end

    replies_data = {}
    replies = {}
    CSV.foreach("db/replies.csv") do |row|
      id, pair_id, word_id, count = row
      next if id == 'id'
      replies_data[id] = { pair_id: pair_id, word: words[word_id], count: count.to_i }
      replies[pair_id] = []
    end
    replies_data.keys.each do |reply|
      replies[replies_data[reply][:pair_id]] << { word: replies_data[reply][:word], count: replies_data[reply][:count] }
    end

    counter = 0
    puts ''

    replies_data = nil
    pairs = {}
    CSV.foreach("db/pairs.csv") do |row|
      id, chat_id, first_id, second_id = row
      next if id == 'id' || ( second_id.nil? && first_id.nil? )
      pair_ids = Word.to_ids([words[first_id], words[second_id]])
      pair = Pair.find_or_create_by!(chat_id: chat_id.to_i, first_id: pair_ids.first, second_id: pair_ids.second)
      counter += 1
      replies[id].each do |reply|
        next if first_id.nil? && reply[:word].nil?
        print "Pair-#{counter}: #{id}-#{words[first_id]}-#{words[second_id]}-#{reply[:word]}                                            \r"
        word_id = Word.find_by(word: reply[:word])&.id
        db_reply = pair.replies.find_or_create_by(word_id: word_id)
        db_reply.increment!(:count, reply[:count])
      end
    end
  end
end
