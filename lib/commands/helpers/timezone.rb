require_relative '../../config'

require 'active_support/time'

class TimezoneConverter
  include ActiveSupport

  attr_accessor :users

  def initialize
    @users = {}
    Config.users.each do |user, attr|
      timezone = attr.timezone
      next unless timezone

      @users[user] = timezone
    end
  end

  def convert_time(unix_epoch)
    result = {}
    @users.each do |u, tz|
      datetime = Time.at(unix_epoch.to_i).to_datetime
      result[u] = datetime.in_time_zone(tz)
    end
    result
  end
end
