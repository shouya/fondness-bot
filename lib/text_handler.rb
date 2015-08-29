require_relative 'handler'

require_relative 'commands/list'
require_relative 'commands/wiki'

class TextHandler < Handler
  include Commands

  def initialize(*)
    super

    [
      List,
      Wikipedia
    ].each do |x|
      add_handler(x.new)
    end
  end
end
