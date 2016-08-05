# Use specific type of unit subclass (Company, Town etc)
# instead of general one (Unit)
# for selecting units of specific type
class Unit
  attr_reader :id, :type, :user, :x, :y

  ATTACK_COST = 1

  @@id_seq = 1
  # id -> unit
  @@units = {}

  # @user User
  # change user_id to user
  def initialize(type, user = nil)
    @id = @@id_seq
    @@id_seq += 1
    @type = type
    @user = user
    @dead = false
    @x = nil
    @y = nil
    @def = 0
    @ap = @max_ap = 0
    @hp = @max_hp = 1
    @@units[@id] = self
  end

  def to_hash()
    hash = {}
    self.instance_variables.each do |var|
      if var == :@user
        if @user
          hash[:@user_name] = @user.login
          hash[:@user_id] = @user.id
        end
      elsif var == :@banner
        # id?
      else
        hash[var] = self.instance_variable_get var
      end
    end
    hash
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
  end

  def user_id
    if @user
      @user.id
    else
      nil
    end
  end
  
  def dead?
    @dead
  end

  def alive?
    !dead?
  end

  def take_dmg(income_dmg)
    reduced_dmg = income_dmg - @def
    reduced_dmg = 1 if reduced_dmg < 1
    @hp -= reduced_dmg
    if @hp <= 0
      die
    end
    reduced_dmg
  end

  def die
    @dead = true
  end

  def dmg
    @dmg + Random.rand(@dmg)
  end

  def place(x = nil, y = nil)
    @x = x
    @y = y
  end

  def move_to(x, y, cost)
    place(x, y)
    @ap -= cost
  end

  def can_move?(cost)
    @ap >= cost
  end

  def move(cost)
    if @ap >= cost
      @ap -= cost
    end
  end

  # game loop function called every `n` seconds
  def tick
    restore_ap
    restore_hp
  end

  # restore some amount of @ap per tick
  def restore_ap
    if @ap <= @max_ap - 1
      @ap += 1
    end
  end

  def restore_hp
    if @hp <= @max_hp - 1
      @hp += 1
    end
  end

  class << self
    def all
      @@units
    end

    def count
      @@units.length
    end

    def get id
      @@units[id]
    end

    def delete id
      @@units.delete id
    end

    def select_active_unit user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :company}.first
    end

    def place_is_empty?(x, y)
      @@units.select{|k,unit| unit.x == x && unit.y == y}.length == 0
    end

    def get_by_user user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :town}.first
    end

    def has_town? user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :town}.length == 1
    end    

    def has_heroes? user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :company}.length > 0
    end

    def has_units? user
      @@units.values.select{|unit| unit.user_id == user.id}.length > 0
    end

    def all_units_count user
      @@units.values.select{|unit| unit.user_id == user.id}.length
    end

    def get_active_unit user
      begin
        active_unit_id = user.active_unit_id
        unit = @@units[active_unit_id]
      rescue
        unit = select_active_unit user
        user.active_unit_id = unit.id
      end
      unit
    end
    
  end

end

class Company < Unit
  #attr_reader :dmg, :def

  MAX_SQUADS = 10
  BASE_DMG = 30
  BASE_HP = 50
  BASE_AP = 20
  BASE_DEF = 10

  def initialize(user, banner)
    super(:company, user)
    @banner = banner
    @banner.unit = self
    @dmg = (BASE_DMG * banner.mod_dmg).round(0)
    @def = (BASE_DEF * banner.mod_def).round(0)
    # @hp - hp of 1st squad in line
    @hp = @max_hp = (BASE_HP * banner.mod_max_hp).round(0)
    @ap = @max_ap = (BASE_AP * banner.mod_max_ap).round(0)
    # each company starts with one squad
    @squads = 1
  end

  def die
    super
    @banner.unit = nil
  end

  def add_squad
    if @squads < MAX_SQUADS
      @squads += 1
    end
  end

  def take_dmg(income_dmg)
    total_hp = @max_hp * (@squads - 1) + @hp
    reduced_dmg = income_dmg - (@def * @squads)
    reduced_dmg = 1 if reduced_dmg < 1
    total_hp -= reduced_dmg
    if total_hp <= 0
      die()
    else
      @squads = total_hp / @max_hp
      modulus = total_hp % @max_hp
      if modulus > 0
        @squads += 1
        @hp = modulus
      else
        @hp = @max_hp
      end
    end
    reduced_dmg
  end

  def dmg
    @squads * (@dmg + Random.rand(@dmg * 0.2)).round(0)
  end

  class << self
    def has_any? user
      @@units.select{|id, unit| unit.user_id == user.id && unit.type == :company}.length > 0
    end
  end

end

class BotCompany < Company
  def initialize(user)
    super(user)
    @hp = 300
    @dmg = 20
  end
end

class GreenOrb < Unit
  MAX_ORBS = 20

  def initialize()
    super(:orb)
    @hp = 100
    @dmg = 20
    @def = 3
  end

  class << self
    def length
      @@units.select{|k,unit| unit.type == :orb}.length
    end

    def below_limit?
      self.length < MAX_ORBS
    end
  end
end

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
    @ttc = nil
    @finish_time = nil
    start_default_res_collection
  end

  def start_default_res_collection
    start_res_collection :gold
  end

  def start_res_collection res_type
    @type = res_type
    @ttc = Resource::T[@type][:ttc]
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

  def initialize(user)
    super(:town, user)
    @hp = @max_hp = 300
    @dmg = 5
    @def = 50
    @inventory = {
      :gold => 50,
      :wood => 50,
      :stone => 0
    }
    @workers = [TownWorker.new, TownWorker.new, TownWorker.new]
    @buildings = {
      #:tavern => Tavern.new,
      :barracs => Barracs.new,
      :banner_shop => BannerShop.new
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

  def set_free_worker_to x, y, type
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
          worker.start_res_collection type
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

  def can_buy_banner?
    raise OrbError, 'Banner shop is not built' unless @buildings[:banner_shop].built?
    raise OrbError, 'Not enough gold to buy banner' unless @inventory[:gold] >= BannerShop::BANNER_COST
    true
  end

  def can_form_company?
    raise OrbError, 'Barracs is not built' unless @buildings[:barracs].built?
    raise OrbError, 'Not enough gold to form company' unless @inventory[:gold] >= Barracs::COMPANY_COST
  end

  def pay_banner_price
    @inventory[:gold] -= BannerShop::BANNER_COST
  end

  def pay_company_price
    @inventory[:gold] -= Barracs::COMPANY_COST
  end

  # select actions available based on constructed buildings for town menu
  def update_actions
    @actions = @buildings.values.map{|b| b.actions}.flatten
  end

  class << self
    def has_any? user
      @@units.select{|id, unit| unit.user_id == user.id && unit.type == :town}.length > 0
    end
  end
end
