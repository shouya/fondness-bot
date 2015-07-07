require 'forwardable'
require 'telegram_bot'

require_relative 'logger'
require_relative 'commander'

class Bot
  extend Forwardable

  def_delegators :@bot, :send_chat_action

  attr_accessor :bot

  def initialize
    @bot = TelegramBot.new(token: Config.telegram.token)
    @bot.listen(method: :poll,
                interval: Config.telegram.poll_interval)

    @logger = MessageLogger.new
    @commander = Commander.new(self)

    setup_message_logger
    setup_command_handlers
  end

  def setup_message_logger
    logger = @logger
    @bot.on :anything, pass: true do
      logger.log(self, message)
    end
  end

  def setup_command_handlers
    commander = @commander
    @bot.on :command, pass: true do |cmd, *args|
      commander.handle(self, cmd, args)
    end
  end

  def start!
    trap :INT do
      @bot.stop!
    end

    @bot.start!
  end

end
