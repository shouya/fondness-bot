require 'singleton'

require_relative '../../config'

class UserUtilClass
  include Singleton

  attr_accessor :users

  def initialize
    @users = Config.users

    @id_map    = {}
    @alias_map = {}


    @users.to_h.each do |u, attr|
      attr['ids'].each     { |id| @id_map[id]    = @users[u] }
      attr['aliases'].each { |al| @alias_map[al] = @users[u] }
    end
  end

  def from_id(id)
    @id_map[id]
  end

  def from_alias(al)
    @alias_map[al]
  end

  def from_name(name)
    @users[name]
  end
end

UserUtil = UserUtilClass.instance
