require 'action'

class User
  attr_reader :login, :id, :glory, :max_glory
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
    @glory = Config.get('START_GLORY')
    @max_glory = Config.get('START_MAX_GLORY')
    # init with false, create default hero on later
    # and switch actions
    add_action NewTownAction.new false
    add_action NewRandomInfantryAction.new false
  end

  def tick
    if @glory < @max_glory
      @glory += 1
    end
  end

  def add_action action
    @actions[action.name] = action
  end

  def enable_new_town_action
    @actions[NewTownAction::NAME].on!
    @actions[NewRandomInfantryAction::NAME].off!
  end

  def enable_new_random_infantry_action
    @actions[NewTownAction::NAME].off!
    @actions[NewRandomInfantryAction::NAME].on!
  end

  def disable_new_town_action
    @actions[NewTownAction::NAME].off!
  end

  def disable_new_random_infantry_action
    @actions[NewRandomInfantryAction::NAME].off!
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

    def drop_all
      @@users = {}
    end
  end
end

class AdminUser < User
  @actions = []
end
