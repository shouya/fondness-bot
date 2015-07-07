#!/usr/bin/env ruby

require_relative '../lib/bot'

def main
  @bot = Bot.new
  @bot.start!
end

if __FILE__ == $0
  main
end
