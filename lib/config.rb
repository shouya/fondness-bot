require 'recursive-open-struct'
require 'yaml'

class RecursiveOpenStruct
  def each
    @table.each_key do |k|
      yield(k, self[k]) if block_given?
    end
  end
end


class ConfigClass
  include Singleton

  CONFIG_PATH = File.expand_path('../../config/app.yml', __FILE__)

  attr_accessor :config
  def initialize(path = CONFIG_PATH)
    @config = RecursiveOpenStruct.new(YAML.load_file(path),
                                      recurse_over_arrays: true)
  end

  def method_missing(m, *args, &block)
    @config.send(m, *args, &block)
  end
end

Config = ConfigClass.instance
