require 'unit'
require 'single_entity'
require 'transport'
require 'town_worker'
require 'map_helper'

##
# SE - single entity
class Town < Unit
  include SingleEntity
  include Transport
  include MapHelper

  attr_reader :buildings, :actions

  TYPE = :town

  def initialize(x, y, user)
    super(TYPE, x, y, user)
    @buildings = {
      :tavern => Tavern.new,
      :barracs => Barracs.new,
      :roads => Roads.new,
      :factory => Factory.new,
      :sawmill => Sawmill.new,
      :quarry => Quarry.new,
      :farm => Farm.new
    }
    bc = BuildingContainer.new(@buildings)
    @workers = {
      1 => TownWorker.new(1, bc),
      2 => TownWorker.new(2, bc),
      3 => TownWorker.new(3, bc)
    }
    @workers.each_value{|w|
      w.start_res_collection(:gold, 0)
    }
    @actions = []
    # start capital for testing
    @inventory[:gold] = 300
    @inventory[:wood] = 50
    @name = I18n.t('Town')
    @radius = Config[:town][:radius].to_i
  end

  ##
  # Destroy all building if town is beign attacked
  # TODO: log building destruction
  # TODO: destory one building per attack, before inflicting wounds

  def wound
    @buildings.each_value{|building|
      if building.built?
        # puts 'destroy ' + building.name
        building.destroy
        break
      end
    }
    super
  end

  def to_hash
    hash = super
    hash.merge!(
      {
        :buildings => @buildings,
        :workers => @workers,
        :radius => @radius
      }
    )
    hash
  end

  def tick
    super
    @workers.each_value{|worker|
      @inventory[worker.type] += worker.collect_res
    }
  end

  ##
  # {type} - symbol

  def set_worker_to(pos, x, y, type)
    worker = get_worker_by_pos(pos)
    # w_at_xy = get_worker_at(x, y)
    # raise OrbError, "Worker is already on #{x}, #{y}" if w_at_xy
    # raise OrbError, "No free workers" if worker.nil?
    if worker && (worker.x != x || worker.y != y)
      worker.x = x
      worker.y = y
      # reset mining process only if coordinates are differ
      # Send worker mining gold if he is doing nothing
      # thats bogus!
      # why there can be no type?
      # if type && worker.type != type
      worker.start_res_collection(type, max_diff(@x, @y, x, y))
      # end
    end
  end

  def get_worker_by_pos(pos)
    # TODO: check if worker exists
    @workers[pos]
  end

  def get_building_title(id)
    @buildings[id].name
  end

  ##
  # Start construction
  # +building_id+ - symbol

  def build(building_id)
    raise OrbError, "Unknown building '#{building_id}'" unless @buildings[building_id]
    building = @buildings[building_id]
    raise NotEnoughResources unless building.enough_resources?(@inventory)
    if building.build
      pay_price(building.cost_res)
      update_actions
      return true
    end
    false
  end

  def built?(building)
    @buildings[building].built?
  end

  def check_price(cost)
    msg = nil
    cost.each{|res, value|
      if value > @inventory[res]
        msg += I18n.t('log_entry_not_enough_res', res: res)
      end
    }
    msg
  end

  def in_radius?(x, y)
    max_diff(@x, @y, x, y) <= @radius
  end

  def pay_price(cost)
    cost.each{|res, value|
      @inventory[res] -= value
    }
  end

  # select actions available based on constructed buildings for town menu
  def update_actions
    @actions = @buildings.values.map{|b| b.actions}.flatten
  end

  class << self
    def has_any? user
      @@units.select{|id, unit| unit.user_id == user.id && unit.type == self::TYPE}.length > 0
    end

    def has_town? user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == self::TYPE}.length == 1
    end

    def has_live_town? user
      @@units.values.select{|unit| unit.user_id == user.id && unit.alive? && unit.type == self::TYPE}.length == 1
    end

    def get_by_user user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == self::TYPE}.first
    end

    def all
      @@units.select{|id, unit| unit.type == self::TYPE}
    end

    def alive user = nil
      @@units.select{|id, unit| (!user || unit.user_id == user.id) && unit.type == self::TYPE && unit.alive?}
    end
  end
end
