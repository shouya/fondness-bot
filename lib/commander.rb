require_relative 'commands/sell_moe'
require_relative 'commands/search'

class Commander
  include Commands

  attr_accessor :bot

  def initialize(bot)
    @bot = bot
    @handlers = [
      SellMoe,
      Search
    ].map(&:new)
  end

  def handle(env, cmd_name, args)
    @handlers.each do |handler|
      next unless handler.match?(env, cmd_name, args)
      handler.handle(env, cmd_name, args)
      break unless handler.pass_through?
    end

  rescue

    env.instance_eval do
      send_message 'bot: error'
      send_message $!.message
    end

  end
end
