require_relative 'db'
require_relative 'config'
require_relative 'bot'

require 'active_support'

class MessageLogger
  def log(env, message)
    return unless wanted?(message)

    send_chat_action(env, message)

    record = parse_record(message)
    insert_db(record)
  end

  def send_chat_action(env, message)
    logging_action = Config.telegram.logging_status
    return if logging_action.nil?

    env.instance_eval do
      send_chat_action(logging_action)
    end
  end

  def wanted?(message)
    return false if message.text.to_s.start_with?('/')
    case message.type
    when :text, :photo, :audio, :document,
         :sticker, :video, :location,
         :member_entered, :member_left
      true
    else
      false
    end
  end

  def insert_db(record)
    uniq_keys = record.slice(:message_id, :from, :chat)
    db_rec = DB.messages.where(uniq_keys)

    return :dup if db_rec.count >= 1

    DB.messages.insert(record)
    return :ok
  end

  def parse_record(message)
    rec = {
      message_id: message.id,
      from: message.from.id,
      to: message.chat.id,
      type: message.type.to_s,
      created_at: Time.at(message.date),
      logged_at: Time.now,
      text: message.text
    }

    media = parse_media(message)
    if media
      rec[:media_type] = message.type.to_s
      rec[:media]      = media.to_s
    end

    rec
  end


  def parse_media(message)
    case message.type
    when :text
      media = nil
    when :photo
      media = message.photo.map {|photo|
        "#{photo.width}x#{photo.height}"
      }.join(",")
    when :audio
      media = "#{message.audio.duration}s"
    when :document
      media = message.document.file_name
    when :sticker
      media = message.text
    when :video
      v = message.video
      media = "#{v.width}x#{v.height}#{v.duration}"
    when :location
      l = message.location
      media = "#{l.latitude},#{l.longitude}"
    when :member_entered
      media = dump_user(message.new_chat_participant)
    when :member_left
      media = dump_user(message.left_chat_participant)
    else
      media = nil
    end
    media
  end


  def dump_user(user)
    name =  user.first_name
    name += " #{user.last_name}" if user.last_name
    name += '('
    name += user.username if user.username
    name += '#' + user.id.to_s
    name += ')'
    name
  end
end
