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

  # Select and return all units.
  # Select user`s town and select adjacent companies to it (one can add more
  # squads in barracs)
  def all_units user=nil
    units = Unit.all
    if user
      town = units.values.select{|unit| unit.type == :town && unit.user.id == user.id}.first
      if town
        town.adj_companies.delete_if {|c| true}
        units.each_value{|unit|
          if unit != town && unit.user && unit.user.id == user.id && @map.adj_cells?(town.x, town.y, unit.x, unit.y)
            town.adj_companies.push(unit.id)
          end
        }
      end
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

  def create_default_company user
    company = nil
    empty_cell = empty_adj_cell(Town.get_by_user(user))
    banner = Banner.get_first_free_by_user(user)
    if empty_cell && banner
      company = new_hero user, banner
      user.active_unit_id = company.id
      company.place empty_cell[:x], empty_cell[:y]
    end
    company
  end

  def create_company_from_banner user, banner_id
    company = nil
    empty_cell = empty_adj_cell(Town.get_by_user(user))
    banner = Banner.get_by_id(user, banner_id)
    if empty_cell && banner
      company = new_hero user, banner
      user.active_unit_id = company.id
      company.place empty_cell[:x], empty_cell[:y]
    end
    company
  end

  def add_squad_to_company user, company_id
    company = Company.get company_id
    company && company.add_squad()
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
    town.build building_id
  end

  def create_random_banner user
    banner = nil
    if Banner.get_count_by_user(user) < MAX_BANNERS
      banner = Banner.new user
    end
    banner
  end

  def delete_banner(user, banner_id)
    Banner.delete user, banner_id
  end

  TER2RES = {
    :grass => nil,
    :tree => :wood,
    :mountain => :stone
  }

  def set_free_worker_to_xy(user, town_id, x, y)
    town = Town.get_by_user user
    raise OrbError, 'No user town' unless town
    raise OrbError, 'You are trying to set worker at town coordinates' if town.x == x && town.y == y
    raise OrbError, 'Cell is not near town' unless @map.adj_cells?(x, y, town.x, town.y)
    type = TER2RES[@map.cell_type_at(x, y)]
    town.set_free_worker_to x, y, type
  end

  def free_worker(user, town_id, x, y)
    town = Town.get_by_user user
    raise OrbError, 'No user town' unless town
    raise OrbError, 'You are trying to free worker at town coordinates' if town.x == x && town.y == y
    raise OrbError, 'Cell is not near town' unless @map.adj_cells?(x, y, town.x, town.y)
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
    res = {:log => nil, :moved => false}
    unit = Unit.get unit_id
    new_x = unit.x + dx
    new_y = unit.y + dy
    type = @map.cell_type_at new_x, new_y
    cost = TYPE2COST[type]
    if unit && unit.can_move?(cost)
      if Unit.place_is_empty?(new_x, new_y) && @map.has?(new_x, new_y) && @map.d_include?(dx, dy)
        unit.move_to(new_x, new_y, cost)
        res[:moved] = true
        res[:new_x] = new_x
        res[:new_y] = new_y
      else
        res[:moved] = false
      end
    else
      puts 'Risen dead'
      res[:log] = 'Your hero is dead'
    end
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

  #################### ATTACK ##################################################
  # a - attacker, {x,y} defender`s coordinates
  # @param [User] a_user attacker
  # @param [Integer] def_id if of the defender unit
  def attack a_user, active_unit_id, def_id
    a = Unit.get_active_unit a_user
    d = Unit.get def_id
    res = Attack.attack a, d
    if res[:a_data][:dead]
      bury(a)
    end
    if res[:d_data][:dead]
      bury(d)
    end
    res
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

