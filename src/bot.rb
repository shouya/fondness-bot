require_relative 'logger'
require_relative 'forwardable'

class BotClass
  extend Forwardable

  def_delegators :@bot, :send_chat_action

  attr_accessor :bot

  def initialize
    @bot = TelegramBot.new(token: Config.telegram.token)
    @bot.listen(method: :poll,
                interval: Config.telegram.poll_interval)

    @logger = Logger.new(self)
  end

  def setup_message_logger
    @bot.on :anything, block: false do
      @logger.log(message)
    end
  end

  def setup_command_handler
    @bot.on :text do

    end
  end


end

Bot = BotClass.instance
