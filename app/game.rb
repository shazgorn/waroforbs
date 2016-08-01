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
      user.actions[:new_hero] = false
      unless Unit.has_town? user
        user.actions[:new_town] = true
      end
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

  def new_town(user, active_unit_id)
    unless Unit.has_town? user
      hero = Company.get active_unit_id
      empty_cell = empty_adj_cell hero
      if empty_cell
        town = Town.new(user)
        town.place empty_cell[:x], empty_cell[:y]
        user.actions[:new_town] = false
      end
    end
  end

  ##################### TOWN BUILDINGS ACTIONS #################################
  def build user, building_id
    town = Town.get_by_user user
    town.build building_id
  end

  def create_default_banner user
    banner = nil
    if Banner.get_count_by_user(user) < MAX_BANNERS
      banner = Banner.new user
    end
    banner
  end
  #################  END TOWN BUILDINGS  #######################################
  ##################### END CONSTRUCTORS #######################################

  def move_hero_by user, unit_id, dx, dy
    res = {:log => nil, :moved => false}
    unit = Unit.get unit_id
    if unit && unit.ap >= 1
      new_x = unit.x + dx
      new_y = unit.y + dy
      if Unit.place_is_empty?(new_x, new_y) && @map.has?(new_x, new_y) && @map.d_include?(dx, dy)
        unit.move_to(new_x, new_y)
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
    Attack.attack a, d
  end
  
end

