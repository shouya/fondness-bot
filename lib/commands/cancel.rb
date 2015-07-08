require_relative 'regular_command'
require_relative 'helpers/timezone'
require_relative 'helpers/user_util'
require_relative 'helpers/pagination'
require_relative 'helpers/parse_query'
require_relative 'helpers/keyword_query'

module Commands
  class Cancel < RegularCommand 'cancel'
    def handle(env, cmd, args)
      env.instance_eval do
        send_message('request cancelled',
                     reply_markup: {
                       hide_keyboard: true
                     })
      end
    end
  end
end
