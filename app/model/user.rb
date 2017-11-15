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
    # init with false, create default hero on later
    # and switch actions
    add_action NewTownAction.new false
    @glory = Config.get('START_GLORY')
    @max_glory = Config.get('START_MAX_GLORY')
    @next_glory_tick = Time.now.to_i
  end

  def reset_glory
    if @glory > Config.get('START_GLORY')
      @glory = Config.get('START_GLORY')
    end
  end

  def tick
    if @glory < @max_glory && @next_glory_tick < Time.now.to_i
      @next_glory_tick += 300 - @max_glory + @glory
      @glory += 1
    end
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

  def pay_glory(glory)
    @glory -= glory
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
