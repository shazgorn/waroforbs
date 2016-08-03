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
      :new_town => true,
      :new_hero => false
    }
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
  def initialize(login)
    super(login)
    @hero = BotCompany.new(@login)
  end
end
