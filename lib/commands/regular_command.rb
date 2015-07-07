module Commands
  def RegularCommand(cmd_name)
    Class.new do
      attr_accessor :command

      define_method(:initialize) {
        @command = cmd_name
      }

      define_method(:match?)  { |env, msg, args|
        x.downcase == cmd_name.downcase
      }

      define_method(:pass_through?) { false }

      define_method(:handle) { |env, msg, args|
        env.instance_eval do
          reply('unknown handler')
        end
      }
    end
  end
end
