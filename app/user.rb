require_relative 'action'

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
    add_action NewHeroAction.new false
  end

  def add_action action
    @actions[action.name] = action
  end

  def enable_new_town_action
    @actions[NewTownAction::NAME].on!
    @actions[NewHeroAction::NAME].off!
  end

  def enable_new_hero_action
    @actions[NewTownAction::NAME].off!
    @actions[NewHeroAction::NAME].on!
  end

  def disable_new_town_action
    @actions[NewTownAction::NAME].off!
  end

  def disable_new_hero_action
    @actions[NewHeroAction::NAME].off!
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
  @actions = []
end
