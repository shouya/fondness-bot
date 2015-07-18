require_relative 'auth'

class Handler
  include Authenticate

  attr_accessor :bot

  def initialize(bot)
    @bot = bot
    @handlers = []
  end

  def add_handler(handler)
    @handlers << handler
  end

  def handle(env, *args)
    user_id = env.instance_eval {
      message.from.id
    }

    if not allowed?(user_id)
      env.instance_eval {
        reply Config.fondbot.denial_message
      }
      return
    end

    @handlers.each do |handler|
      next unless handler.match?(env, *args)
      handler.handle(env, *args)
      break unless handler.pass_through?
    end

  rescue

    env.instance_eval do
      msg =  "bot: error\n"
      msg << $!.message << "\n"
      msg << $!.backtrace.first(5).join("\n")
      send_message msg
    end

  end
end
