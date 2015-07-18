module Commands
  def self.RegularText(matcher)
    Class.new do
      attr_accessor :matcher

      define_method(:initialize) {
        @matcher = matcher
      }

      define_method(:match?)  { |env, text|
        text === @matcher
      }

      define_method(:pass_through?) { false }

      define_method(:handle) { |env, *args|
        env.instance_eval do
          reply('unknown handler')
        end
      }
    end
  end

end
