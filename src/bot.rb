require_relative 'logger'
require_relative 'commander'
require_relative 'forwardable'

class Bot
  extend Forwardable

  def_delegators :@bot, :send_chat_action

  attr_accessor :bot

  def initialize
    @bot = TelegramBot.new(token: Config.telegram.token)
    @bot.listen(method: :poll,
                interval: Config.telegram.poll_interval)

    @logger = Logger.new(self)
    @commander = Commander.new(self)

    setup_message_logger
    setup_command_handlers
  end

  def setup_message_logger
    @bot.on :anything, block: false do
      @logger.log(self, message)
    end
  end

  def setup_command_handlers
    @bot.on :command, block: false do |cmd, *args|
      @commander.handle(self, cmd, args)
    end
  end

  def start!
    @bot.start!
  end

end
