require_relative 'regular_command'

module Commands
  class SellMoe < RegularCommand 'sell_moe'
    def handle(env, cmd, args)
      env.instance_eval do
        send_message('mew~')
      end
    end

  end
end
