require 'thread/pool'
require 'queue'
require 'json'
require 'recursive_open_struct'

require_relative 'twitter_api_wrapper'

class Crawler
  CONFIG_PATH = File.expand_path('../../config/crawler.json', __FILE__)

  def init(config_path = CONFIG_PATH)
    @client = TwitterAPIWrapper.new
    @db     = DB.new
    @queue  = Queue.new
    @config = RecursiveOpenStruct.new(JSON.parse(File.read(config_path)))
    @pool   = Thread.pool(@config.thread_pool_size)
  end

  def init_queue
    @config.victims.each do |name, conf|
      @queue.push({ :type => :timeline,  :user => name}) if conf.timeline
      @queue.push({ :type => :favorites, :user => name}) if conf.favorites
    end
  end


  def run
    loop do
      @pool.process do
        crawl
      end
    end
  end

  def crawl
    sleep 1 while @queue.empty?

    task = @queue.pop
    return @queue.push(task) if task[:time] > Time.now

    case task[:type]
    when :status
      crawl_status(task[:id])
    when :timeline
      crawl_timeline(task[:user])
    when :fav
      crawl_fav(task[:user])
    end
  end

  private

  def crawl_timeline(user)
    since_id = @db.read_cursor(user, 'timeline')
    victim = @config.victims[user]

    inc_rts     = victim.user
    inc_replies = victim.replies

    tweets = @client.user_timeline(user,
                                   since_id: since_id,
                                   include_rts: inc_rts,
                                   exclude_replies: !inc_replies)

    tweets.each do |t|
      if t.reply?
        @queue.push(:type => :status,
                    :id   => t.in_reply_to_tweet_id,
                    :time => Time.now)
      end
      save_tweet(t)
    end

    @db.write_cursor(user, 'timeline', tweets.first.id)
    @queue.push(:type => :timeline,
                :user => user,
                :time => Time.now + victim.timeline_crawling_interval)
  end

  def crawl_fav(user)
    since_id = @db.read_cursor(user, 'fav')
    victim = @config.victims[user]

    tweets = @client.favorites(user,
                               since_id: since_id)
    tweets.each do |t|
      save_tweet(t, 'fav')
    end

    @db.write_cursor(user, 'fav', tweets.first.id)
    @queue.push(:type => :timeline,
                :user => user,
                :time => Time.now + victim.favorites_crawling_interval)
  end

  def crawl_status(id)
    tweet = @cient.status(id)
    save_tweet(tweet)
  end

  def save_tweet(t, type = nil)
    ref_tweet_id = t.in_reply_to_tweet_id
    guessed_type = guess_tweet_type(t)

    tweet_params = {
      onwer:        user,
      content:      t.text,
      type:         type || guessed_type,
      tweet_id:     t.id,
      ref_tweet_id: ref_tweet_id,
      rt_count:     t.retweet_count,
      fav_count:    t.fav_count,
      timestamp:    t.created_at
    }

    @db.tweets.insert(tweet_params)
  end

  def guess_tweet_type(t)
    case
    when t.retweet? then 'retweet'
    when t.reply?   then 'reply'
    else                 'status'
    end
  end
end
