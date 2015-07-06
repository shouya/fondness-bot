# merge history exported using https://github.com/psamim/telegram-cli-backup

require 'sequel'
require 'active_support'
require 'ruby-progressbar'

db_file = ARGV.shift

NAME_MAPPING = {
  'C1'    => 52177891,
  'C2'    => 42294863,
  'shou'  => 48273646,
  '吃吃吃' => 2998214
}

def name_to_id(name)
  if n = NAME_MAPPING[name]
    return n
  else
    abort "name not found [#{name}]"
  end
end

def deduce_type(msg)
  return 'text' if msg[:media_type].nil?
  return msg[:media_type]
end

def already_logged(outmsg, msg)
  outmsg.where(:message_id => msg[:message_id],
               :created_at => Time.at(msg[:date]))
    .count > 0
end

outdb = Sequel.sqlite('data.db')


outdb.create_table? :messages do
  primary_key :id
  Integer     :message_id, null: false
  Integer     :from,       null: false
  Integer     :to,         null: false
  String      :text
  String      :type,       null: false
  String      :media_type
  String      :media
  DateTime    :created_at
  DateTime    :logged_at
end



outmsg = outdb[:messages]
inmsg = Sequel.sqlite(db_file)[:messages]

pbar = ProgressBar.create(total: inmsg.count,
                          throttle_rate: 0.2,
                          format: '%e|%bᗧ%i %p%%(%c/%C)',
                          progress_mark: ' ',
                          remainder_mark: '･')

outdb.transaction do
  inmsg.each do |m|
    # next if already_logged(outmsg, m)
    pbar.increment
    outmsg.insert(message_id: m[:message_id],
                  from: name_to_id(m[:from]),
                  to: name_to_id(m[:to]),
                  text: m[:text],
                  type: deduce_type(m),
                  media: m[:media],
                  created_at: Time.at(m[:date]).to_datetime,
                  logged_at: Time.now)
  end
end
