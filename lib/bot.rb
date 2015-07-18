require 'forwardable'
require 'telegram_bot'

require_relative 'logger'
require_relative 'text_handler'
require_relative 'command_handler'

class Bot
  extend Forwardable

  def_delegators :@bot, :send_chat_action

  attr_accessor :bot

  def initialize
    @bot = TelegramBot.new(token: Config.telegram.token)
    @bot.listen(method: :poll,
                interval: Config.telegram.poll_interval)

    @logger          = MessageLogger.new

    @text_handler    = TextHandler.new(self)
    @command_handler = CommandHandler.new(self)

    setup_message_logger

    setup_command_handlers
    setup_text_handlers
  end

  def setup_message_logger
    logger = @logger
    @bot.on :anything, pass: true do
      logger.log(self, message)
    end
  end

  def setup_command_handlers
    commander = @command_handler
    @bot.on :command, pass: true do |cmd, *args|
      commander.handle(self, cmd, args)
    end
  end

  def setup_text_handlers
    commander = @text_handler
    @bot.on :text, pass: true do |text|
      commander.handle(self, text)
    end
  end

  def start!
    trap :INT do
      @bot.stop!
    end

    @bot.start!
  end

end
