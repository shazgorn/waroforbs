class User
  attr_reader :login, :id
  attr_accessor :active_unit_id, :actions

  @@id_seq = 1
  # id -> user
  @@users = {}

  def initialize(login)
    @id = @@id_seq
    @@id_seq += 1
    @login = login
    @active_unit_id = nil
    @actions = {
      :action_new_town => true,
      :action_new_hero => false
    }
  end

  def set_action_new_town value
    @actions[:action_new_town] = value
  end

  def set_action_new_hero value
    @actions[:action_new_hero] = value
  end

  def actions_arr
    @actions.select{|k,v| v == true}.keys
  end

  class << self
    def new login
      user = super login
      @@users[user.id] = user
    end

    def get id
      @@users[id]
    end

    def all
      @@users
    end
  end
end

class AdminUser < User
  @actions = [:spawn_bot]
end

class Bot < User

end
