
require_relative 'regular_command'
require_relative '../db'

module Commands
  class List < RegularCommand 'list'
    def add(list, text)
      DB.lists.insert(list: list,
                      content: text,
                      created_at: Time.now)
      "item [#{text}] added to #{list}."
    end

    def del(list, index)
      item = DB.lists
             .where(list: list)
             .order_by(:created_at)
             .limit(1)
             .offset(index - 1)

      if item.count == 0
        "no item selected."
      else
        record = item.to_a[0]
        text = record[:content]
        DB.lists.where(id: record[:id]).delete
        "[#{text}] removed from #{list}."
      end
    end

    def clear(list)
      items = DB.lists.where(list: list)
      items.delete

      "#{list} removed."
    end

    def show_list(list)
      items = DB.lists.where(list: list).order_by(:created_at)

      if items.count == 0
        return "#{list} contains no item."
      end

      out = list.to_s + ":\n"

      items.each_with_index do |itm, idx|
        out << "\t#{idx + 1}. #{itm[:content]}\n"
      end
      out
    end

    def lists
      ls = DB.lists.order_by(:created_at).group(:list)

      return "no lists." if ls.empty?

      out = 'lists available:'
      ls.each_with_index do |l, i|
        out << "\t#{i+1}. #{l[:list]}\n"
      end
      out
    end

    def parse_list_name(text)
      result = text.split.select { |a| a =~ /^#.*list\d*$/ }
      return nil if result.empty?
      return nil if result.count > 1
      return result[0]
    end

    def parse_args(list, text)
      text = text.gsub(list, '').strip
      case text.split[0]
      when nil
        [:print]
      when 'del'
        [:del, text.split[1].to_i]
      when 'clear'
        [:clear]
      else
        [:add, text]
      end
    end

    def match?(env, *args)
      text = env.instance_eval { message.text }
      !!parse_list_name(text)
    end

    def handle(env, *anything)
      text = env.instance_eval { message.text }
      list = parse_list_name(text)
      action, *args = parse_args(list, text)

      msg = case action
            when :print
              show_list(list)
            when :add
              add(list, args[0])
            when :del
              del(list, args[0].to_i)
            when :clear
              clear(list)
            end

      env.instance_eval do
        send_message(msg)
      end
    end
  end
end
