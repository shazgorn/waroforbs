require 'action'

class User
  attr_reader :login, :id
  attr_accessor :active_unit_id, :actions

  @@id_seq = 1
  # id -> user
  @@users = {}

  def initialize login
    @id = @@id_seq
    @@id_seq += 1
    @login = login
    @active_unit_id = nil
    @actions = {}
    # init with false, create default hero on later
    # and switch actions
    add_action NewTownAction.new false
  end

  def tick
  end

  def add_action action
    @actions[action.name] = action
  end

  def enable_new_town_action
    @actions[NewTownAction::NAME].on!
  end

  def disable_new_town_action
    @actions[NewTownAction::NAME].off!
  end

  class << self
    def new(login)
      @@users.each{|id, user|
        return user if user.login == login
      }
      user = super login
      @@users[user.id] = user
    end

    def get id
      @@users[id]
    end

    def all
      @@users
    end

    def drop_all
      @@users = {}
    end
  end
end

class AdminUser < User
  @actions = []
end
