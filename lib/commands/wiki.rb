
require_relative 'regular_command'
require_relative '../db'

require 'cgi'

module Commands
  class Wikipedia < RegularCommand 'wiki'
    def match?(env, *args)
      text = env.instance_eval { message.text }
      $session[:wiki] or text == '搜索'
    end

    def handle(env, *anything)
      $session[:wiki] ||= {}
      $session[:wiki][:env] = env

      stage = $session[:wiki][:stage] || 'default'
      $session[:wiki][stage] = env.instance_eval {message.text}

      keyword  = $session[:wiki][:keyword]
      return ask_keyword(env) unless keyword

      provider = $session[:wiki][:provider]
      return ask_provider(env) unless provider

      link = construct_link(provider, keyword)
      env.instance_eval do
        reply(link)
      end
      $session[:wiki] = nil
    end

    def ask_keyword(env)
      env.instance_eval do
        reply("請輸入關鍵字",
              reply_markup: {
                force_reply: true,
                selective: true
              })
      end
      $session[:wiki][:stage] = :keyword
    end

    def ask_provider(env)
      env.instance_eval do
        reply("在哪裡搜索？",
              reply_markup: {
                keyboard: [["google"],
                           ["baidu"],
                           ["wikipedia (zh)"],
                           ["wikipedia (en)"],
                           ["cancel"]],
                one_time_keyboard: true,
                selective: true
              })
      end
      $session[:wiki][:stage] = :provider
    end

    def e(keyword)
      CGI.escape(keyword)
    end

    def construct_link(provider, keyword)
      case provider
      when "google"
        "https://www.google.com/search?q=#{e(keyword)}&ie=UTF-8"
      when "baidu"
        "https://www.baidu.com/s?wd=#{e(keyword)}"
      when "wikipedia (zh)"
        "https://zh.wikipedia.org/wiki/w/search.php?search=#{e(keyword)}"
      when "wikipedia (en)"
        "https://en.wikipedia.org/wiki/w/search.php?search=#{e(keyword)}"
      end
    end
  end
end
