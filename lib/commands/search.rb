
require_relative 'regular_command'
require_relative 'helpers/timezone'
require_relative 'helpers/user_util'
require_relative 'helpers/pagination'
require_relative 'helpers/parse_query'
require_relative 'helpers/keyword_query'

module Commands
  class Search < RegularCommand 'search'
    include QueryParser
    include Pagination
    include KeywordQuery

    SEPARATOR_WIDTH = 40

    def match?(env, cmd, args)
      %w[s search].include? cmd.downcase
    end

    def search(args, limit = 20, page = 1)
      @query = parse_query(args)

      @dataset = keyword_query(DB.messages,
                               :text,
                               @query[:keywords])
      @pagination = paginate_query(@dataset,
                                   @query[:paging])
      # dataset = orderify_query(datatset, query[:order])

      @pagination[:result]
    end

    def encapsulate_result(messages, kws)
      if messages.count == 0
        return "no result"
      end

      @timezone = TimezoneConverter.new

      out = 'search result'
      if @query[:keywords] && !@query[:keywords].empty?
        out << ' for ['
        out << @query[:keywords].join(' ')
        out << ']'
      end
      out << "\n"

      messages.each_with_index do |message, idx|
        out << (idx+1).to_s.center(SEPARATOR_WIDTH, '-') << "\n"
        out << multi_time_string(message[:created_at].to_i) << "\n"
        out << UserUtil.from_id(message[:from]).name << ' said: '
        out << message[:text] << "\n"
      end

      out << '_' * SEPARATOR_WIDTH << "\n"
      out << pagination_text(@pagination) << "\n"

      out
    end

    def multi_time_string(unix_epoch)
      times = @timezone.convert_time(unix_epoch)
      times.to_a.map { |u, t|
        t.strftime("%b %d, %Y %I:%M %p (#{u})")
      }.join(', ')
    end

    def handle(env, cmd, args)
      msgs = search(args)
      out = encapsulate_result(msgs, args)

      env.instance_eval do
        send_message(out)
      end
    end

  end
end
