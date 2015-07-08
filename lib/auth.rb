# allow request only from given users

require_relative 'commands/helpers/user_util'

module Authenticate
  def allowed?(user_id)
    return true if Config.fondbot.public
    authorized_users.include? user_id
  end

  private

  def authorized_users
    return @authorized_users if @authorized_users

    @authorized_users = Config.fondbot.authorized.map { |u|
      UserUtil.from_name(u).ids
    }.flatten
  end
end
