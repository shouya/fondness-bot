require_relative '../db'
require_relative '../config'
require 'telegra_bot'

class Poller
  attr_accessor :bot

  def initialize
    @bot = TelegramBot.new(token: Config.telegram.token)
    @bot.listen(method: :poll,
                interval: Config.telegram.poll_interval)
  end


  def on_message()
  end

  def do_queries
  end

  def run

  end
end
