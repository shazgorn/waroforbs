# Game logic, some kind of incubator
# code from here will be moved to more appropriate places
# like data storage, attack strategy etc
# dead heroes are dead if they never exists
# should move unit creation methods to separate class
class Game
  attr_reader :map
  MAX_BANNERS = 3

  def initialize
    @map = Map.new
    # token -> user_id
    @tokens = {}
  end

  ############ DATA SELECTION METHODS ########################
  def get_user_by_token token
    begin
      user = User.get @tokens[token]
    rescue
      user = nil
    end
    user
  end

  def all_units_for_all units
    units.each_value{|unit|
      if unit.type == :town
        unit.adj_companies = []
        units.each_value{|unit2|
          if unit != unit2 && unit.user && unit.user == unit2.user && @map.adj_cells?(unit.x, unit.y, unit2.x, unit2.y)
            unit.adj_companies.push(unit2.id)
          end
        }
      end
    }
  end

  # Select and return all units.
  # Select user`s town and select adjacent companies to it (one can add more
  # squads in barracs)
  def all_units user=nil
    units = Unit.all
    if user
      town = units.values.select{|unit| unit.type == :town && unit.user.id == user.id}.first
      if town
        town.adj_companies = []
        units.each_value{|unit|
          if unit != town && unit.user && unit.user.id == user.id && @map.adj_cells?(town.x, town.y, unit.x, unit.y)
            town.adj_companies.push(unit.id)
          end
        }
      end
    else
      all_units_for_all units
    end
    units
  end
  ##################### END DATA SELECTION METHODS #######################
  
  ##################### CONSTRUCTORS #####################################
  # init user
  # If this is a 1st login then new user is created
  # new banner
  # and new hero is placed
  def init_user token
    user = get_user_by_token token
    if user.nil?
      user = User.new(token)
      @tokens[token] = user.id
      Banner.new user
      new_random_hero user
    end
    user
  end

  def init_map user
    {
      :map_shift => Map::SHIFT,
      :cell_dim_in_px => Map::CELL_DIM_PX,
      :block_dim_in_cells => Map::BLOCK_DIM,
      :block_dim_in_px => Map::BLOCK_DIM_PX,
      :map_dim_in_blocks => Map::BLOCKS_IN_MAP_DIM,
      :MAX_CELL_IDX => Map::MAX_CELL_IDX,
      :active_unit_id => user.active_unit_id,
      :user_id => user.id,
      :actions => user.actions_arr,
      :banners => Banner.get_by_user(user),
      :units => all_units(user),
      :cells => @map.cells,
      :TOWN_RADIUS => Town::RADIUS,
      :building_states => {
        :BUILDING_STATE_CAN_BE_BUILT => Building::STATE_CAN_BE_BUILT,
        :BUILDING_STATE_IN_PROGRESS => Building::STATE_IN_PROGRESS,
        :BUILDING_STATE_BUILT => Building::STATE_BUILT
      }
    }
  end

  def new_hero user, banner
    Company.new(user, banner)
  end

  # Create new random hero for user if it`s his first login
  # or all other heroes and towns are destroyed
  def new_random_hero user
    unless Unit.has_units? user
      banner = Banner.get_first_by_user user
      hero = new_hero user, banner
      user.active_unit_id = hero.id
      place_at_random hero
      recalculate_user_actions user
    end
  end

  def create_company user, banner_id=:new
    town = Town.get_by_user(user)
    raise OrbError, 'User have no town' if town.nil?
    town.can_form_company?
    company = nil
    empty_cell = empty_adj_cell(town)
    if banner_id == :new
      banner = Banner.get_first_free_by_user(user)
    else
      banner = Banner.get_by_id(user, banner_id)
    end
    if empty_cell && banner
      company = new_hero user, banner
      user.active_unit_id = company.id
      company.place empty_cell[:x], empty_cell[:y]
      town.pay_company_price
    end
    company
  end

  def add_squad_to_company user, town_id, company_id
    town = Town.get_by_user(user)
    raise OrbError, 'User have no town' if town.nil?
    if town.can_add_squad?
      company = Company.get company_id
      raise OrbError, 'No company' unless company
      raise OrbError, 'Company must be near town' unless @map.adj_cells?(town.x, town.y, company.x, company.y)
      town.pay_squad_price()
      company.add_squad()
    end
  end

  def new_town(user, active_unit_id)
    unless Unit.has_town? user
      hero = Company.get active_unit_id
      empty_cell = empty_adj_cell hero
      if empty_cell
        town = Town.new(user)
        town.place empty_cell[:x], empty_cell[:y]
        recalculate_user_actions user
      end
    end
  end

  ##################### TOWN / BUILDINGS ACTIONS #################################
  def build user, building_id
    town = Town.get_by_user user
    raise OrbError, 'User have no town' if town.nil?
    town.build building_id
  end

  def create_random_banner user
    town = Town.get_by_user user
    raise OrbError, 'No user town' unless town
    raise OrbError, 'Banners limit reached. No more than three banners allowed' unless Banner.get_count_by_user(user) < MAX_BANNERS
    raise OrbError, 'Unable to bought banner. Not enough gold or Banner shop is not built' unless town.can_buy_banner?
    town.pay_banner_price
    Banner.new user
  end

  def delete_banner(user, banner_id)
    Banner.delete user, banner_id
  end

  TER2RES = {
    :grass => nil,
    :tree => :wood,
    :mountain => :stone
  }

  def in_town_radius?(town, x, y)
    @map.max_diff(town.x, town.y, x, y) <= Town::RADIUS
  end

  def set_free_worker_to_xy(user, town_id, x, y)
    town = Town.get_by_user user
    raise OrbError, 'No user town' unless town
    raise OrbError, 'You are trying to set worker at town coordinates' if town.x == x && town.y == y
    raise OrbError, 'Cell is not near town' unless in_town_radius?(town, x, y)
    type = TER2RES[@map.cell_type_at(x, y)]
    town.set_free_worker_to x, y, type, @map.max_diff(town.x, town.y, x, y)
  end

  def free_worker(user, town_id, x, y)
    town = Town.get_by_user user
    raise OrbError, 'No user town' unless town
    raise OrbError, 'You are trying to free worker at town coordinates' if town.x == x && town.y == y
    raise OrbError, 'Cell is not near town' unless in_town_radius?(town, x, y)
    town.free_worker_at x, y
  end

  #################  END TOWN BUILDINGS  #######################################
  ##################### END CONSTRUCTORS #######################################

  TYPE2COST = {
    :grass => 1,
    :tree => 2,
    :mountain => 3
  }

  def move_hero_by user, unit_id, dx, dy
    raise OrbError, 'Wrong direction' unless @map.d_include?(dx, dy)
    res = {:log => nil, :moved => false}
    unit = Unit.get unit_id
    raise OrbError, 'No unit' unless unit
    new_x = unit.x + dx
    new_y = unit.y + dy
    raise OrbError, 'Out of map' unless @map.has?(new_x, new_y)
    type = @map.cell_type_at new_x, new_y
    cost = TYPE2COST[type]
    raise OrbError, 'Not enough AP' unless unit.can_move?(cost)
    raise OrbError, 'Cell is occupied' unless Unit.place_is_empty?(new_x, new_y)
    unit.move_to(new_x, new_y, cost)
    res.merge!({:moved => true, :new_x => new_x, :new_y => new_y})
    res[:moved] = false
    res
  end

  def place_at_random unit
    while true
      xy = @map.get_rand_coords
      if Unit.place_is_empty?(xy[:x], xy[:y])
        unit.place(xy[:x], xy[:y])
        break
      end
    end
  end

  def empty_adj_cell unit
    (-1..1).each do |x|
      (-1..1).each do |y|
        new_x = unit.x + x
        new_y = unit.y + y
        if Unit.place_is_empty?(new_x, new_y) && @map.valid?(new_x, new_y)
          return {:x => new_x, :y => new_y}
        end
      end
    end
    nil
  end

  def revive(token)
  end

  def restart(token)
  end

  def tick
    Unit.all.values.each{|unit|
      unit.tick
    }
  end

  def black_orbs_below_limit
    BlackOrb.below_limit?
  end

  def spawn_black_orb
    BlackOrb.new
  end

  #################### ATTACK ##################################################
  def attack_adj_cells a
    (-1..1).each do |adx|
      (-1..1).each do |ady|
        if !(adx == 0 && ady == 0)
          adj_x = a.x + adx
          adj_y = a.y + ady
          d = Unit.get_by_xy adj_x, adj_y
          if d
            return attack a, d
          end
        end
      end
    end
    nil
  end

  # a - attacker, d - defender
  def attack a, d
    raise OrbError, 'Not enough ap to attack' unless a.can_move?(Unit::ATTACK_COST)
    res = Attack.attack a, d
    if res[:a_data][:dead]
      bury(a)
    end
    if res[:d_data][:dead]
      bury(d)
    end
    res
  end

  # @param [User] a_user attacker
  # @param [Integer] def_id if of the defender unit
  def attack_by_user a_user, active_unit_id, def_id
    a = Unit.get_active_unit a_user
    d = Unit.get def_id
    attack a, d
  end

  def bury(unit)
    Unit.delete unit.id
    if unit.user
      recalculate_user_actions unit.user
    end
  end

  def recalculate_user_actions user
    has_town = Town.has_any? user
    has_company = Company.has_any? user
    user.set_action_new_town false
    user.set_action_new_hero false
    if has_company && !has_town
      user.set_action_new_town true
    elsif !has_company && !has_town
      user.set_action_new_hero true
    end
  end
  
end

