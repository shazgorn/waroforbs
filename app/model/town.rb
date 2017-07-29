require 'unit'

class Resource
  T = {
    :gold => {
      :ttc => 20
    },
    :wood => {
      :ttc => 10
    },
    :stone => {
      :ttc => 15
    }
  }
end

class TownWorker < JSONable
  attr_reader :type
  attr_accessor :x, :y

  def initialize
    @x = nil
    @y = nil
    @type = nil
    @start_time = nil
    # time to collect
    @ttc = nil
    @finish_time = nil
    start_default_res_collection
  end

  def start_default_res_collection
    start_res_collection :gold
  end

  def start_res_collection res_type, distance = 1
    @type = res_type
    @ttc = Resource::T[@type][:ttc] * distance
    @start_time = Time.now
    @finish_time = @start_time + @ttc
  end

  def clear
    @x = @y = nil
    start_default_res_collection
  end

  # check if it`s time to collect resource
  def check_res
    if @finish_time && Time.now > @finish_time
      @finish_time += @ttc
      return true
    end
    return false
  end
end

class Town < Unit
  attr_accessor :adj_companies
  attr_reader :buildings, :actions

  TYPE = :town
  RADIUS = 3

  def initialize(x, y, user)
    super(TYPE, x, y, user)
    @damage = 5
    @defence = 50
    @inventory = {
      :gold => 1000,
      :wood => 50,
      :stone => 0
    }
    @workers = [TownWorker.new, TownWorker.new, TownWorker.new]
    @buildings = {
      #:tavern => Tavern.new,
      :barracs => Barracs.new
    }
    @actions = []
    @adj_companies = []
  end

  def tick
    super
    @workers.each{|worker|
      if worker.check_res
        @inventory[worker.type] += 1
      end
    }
  end

  def free_worker_at x, y
    w_at_xy = get_worker_at x, y
    raise OrbError, "No worker at #{x}, #{y}" unless w_at_xy
    w_at_xy.clear
  end

  def set_free_worker_to x, y, type, distance
    w_at_xy = get_worker_at x, y
    raise OrbError, "Worker is already on #{x}, #{y}" if w_at_xy
    if w_at_xy.nil?
      worker = get_free_worker
      raise OrbError, "No free workers" if worker.nil?
      if worker
        worker.x = x
        worker.y = y
        # do send worker mining gold if he is doing nothing
        if type && worker.type != type
          worker.start_res_collection type, distance
        end
        return true
      end
    end
    false
  end

  def get_worker_at x, y
    @workers.select{|w| w.x == x && w.y == y}.first
  end

  def get_free_worker
    @workers.select{|w| w.x == nil && w.y == nil}.first
  end

  def place(x = nil, y = nil)
    if @x.nil? && @y.nil?
      super(x, y)
    end
  end

  def extract_cost cost
    cost.each_pair{|res, count|
      @inventory[res] -= count
    }
  end

  def build building_id
    building = @buildings[building_id]
    raise OrbError, 'Not enough resources' unless building.enough_resources?(@inventory)
    extract_cost building.cost_res
    if building.build
      update_actions
      return true
    end
    false
  end

  def can_form_company?
    raise OrbError, 'Barracs is not built' unless @buildings[:barracs].built?
    raise OrbError, 'Not enough gold to form company' unless @inventory[:gold] >= Barracs::COMPANY_COST
    true
  end

  def can_add_squad?
    raise OrbError, 'Barracs is not built' unless @buildings[:barracs].built?
    raise OrbError, 'Not enough gold to add squad' unless @inventory[:gold] >= Barracs::SQUAD_COST
    true
  end

  def pay_company_price
    @inventory[:gold] -= Barracs::COMPANY_COST
  end

  def pay_squad_price
    @inventory[:gold] -= Barracs::SQUAD_COST
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
  end
end