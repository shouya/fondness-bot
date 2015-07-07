
require_relative 'regular_command'
require_relative 'helpers/timezone'
require_relative 'helpers/user_util'

module Commands
  class Search < RegularCommand 'search'
    SEPARATOR_WIDTH = 40

    def match?(env, cmd, args)
      %w[s search].include? cmd.downcase
    end

    def search_keyword(kws, limit = 5, page = 1)
      floating_kws = kws.map {|kw| "%#{kw}%" }
      DB.messages
        .grep(:text, floating_kws)
        .limit(limit, (page - 1) * limit)
    end

    def encapsulate_result(messages, kws)
      if messages.count == 0
        return "no result"
      end

      @timezone = TimezoneConverter.new

      out =  'search result for messages containing '
      out << kws.join(', ')
      out << "\n"
      messages.each_with_index do |message, idx|
        out << (idx+1).to_s.center(SEPARATOR_WIDTH, '-') << "\n"
        out << multi_time_string(message[:created_at].to_i) << "\n"
        p message[:from]
        p UserUtil.instance_eval { @id_map }
        out << UserUtil.from_id(message[:from]).name << ' said: '
        out << message[:text] << "\n"
      end

      out
    end

    def multi_time_string(unix_epoch)
      times = @timezone.convert_time(unix_epoch)
      times.to_a.map { |u, t|
        t.strftime("%b %d, %Y %I:%M %p (#{u})")
      }.join(', ')
    end

    def handle(env, cmd, args)
      msgs = search_keyword(args)
      out = encapsulate_result(msgs, args)

      env.instance_eval do
        send_message(out)
      end
    end

  end
end
