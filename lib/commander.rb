require_relative 'auth'
require_relative 'commands/sell_moe'
require_relative 'commands/search'
require_relative 'commands/cancel'

class Commander
  include Commands
  include Authenticate

  attr_accessor :bot

  def initialize(bot)
    @bot = bot
    @handlers = [
      Cancel,
      SellMoe,
      Search
    ].map(&:new)
  end

  def handle(env, cmd_name, args)
    user_id = env.instance_eval {
      message.from.id
    }

    if not allowed?(user_id)
      env.instance_eval do
        reply Config.fondbot.denial_message
      end
    end

    @handlers.each do |handler|
      next unless handler.match?(env, cmd_name, args)
      # handler.handle(env, cmd_name, args)
      break unless handler.pass_through?
    end

  rescue

    env.instance_eval do
      msg =  "bot: error\n"
      msg << $!.message << "\n"
      msg << $!.backtrace.join("\n")
      send_message msg
    end

  end
end
