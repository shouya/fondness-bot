require_relative 'regular_command'

module Commands
  class SellMoe < Commands::RegularCommand('sell_moe')
    def handle(env, msg, args)
      env.instance_eval do
        send_message('mew~')
      end
    end

  end
end
