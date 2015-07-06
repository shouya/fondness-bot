require_relative '../db'
require 'twitter'
require 'json'

class TwitterAPIWrapper
  SECRETS_PATH = File.expand_path('../../config/secrets.json', __FILE__)

  def init(secrets_path = SECRETS_PATH)
    cfg_lst = JSON.parse(secrets_path)
    @workers = cfg_lst.map {|cfg| setup_worker(cfg) }
  end

  def method_missing(name, *args, **params, &block)
    class << self
      send :define_method, name do |*args1, **params1, &block1|
        begin
          client = @workers.sample
          client.call(name, *args1, **params1, &block1)
        rescue Twitter::Error
          case $!.code
          when Twitter::Error::Code::RATE_LIMIT_EXCEEDED
            redo
          end
        end
      end
    end

    self.call(name, *args, **params, &block)
  end


  private

  def setup_worker(cfg)
    Twitter::REST::Client.new do |config|
      config.consumer_key        = cfg['consumer_key']
      config.consumer_secret     = cfg['consumer_secret']
      config.access_token        = cfg['access_token']
      config.access_token_secret = cfg['access_token_secret']
    end
  end
end
