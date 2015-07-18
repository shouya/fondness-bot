require_relative 'handler'

require_relative 'commands/list'

class TextHandler < Handler
  include Commands

  def initialize(*)
    super

    [List].each do |x|
      add_handler(x.new)
    end
  end
end
