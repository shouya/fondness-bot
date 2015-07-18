require_relative 'handler'

require_relative 'commands/sell_moe'
require_relative 'commands/search'
require_relative 'commands/cancel'

class CommandHandler < Handler
  include Commands

  def initialize(*)
    super

    [
      Cancel,
      SellMoe,
      Search
    ].each do |x|
      add_handler(x.new)
    end
  end
end
