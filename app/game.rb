# this class gotta contain some logic about units interactions
# and all other non-map things
# dead heroes are dead if they never exists
class Game
  attr_reader :map
  attr_accessor :users, :units

  def initialize
    # id -> user
    @users = {}
    # id -> unit
    @units = {}
    @map = Map.new
    # token -> user_id
    @tokens = {}
  end

  ############ DATA SELECTION METHODS ########################
  def green_orbs_length
    @units.select{|k,unit| unit.type == 'GreenOrb'}.length
  end

  def select_active_unit user
    @units.values{|unit| unit.user_id = user.id && unit.class.name == 'Town'}.first
  end

  def place_is_empty?(x, y)
    @units.select{|k,unit| unit.x == x && unit.y == y}.length == 0
  end

  def get_town user
    @units.values.select{|unit| unit.user == user && unit.class.name == 'Town'}.first
  end

  def get_user_by_token token
    begin
      user = @users[@tokens[token]]
    rescue
      user = nil
    end
    user
  end

  def get_active_unit user
    begin
      active_unit_id = user.active_unit_id
      unit = @units[active_unit_id]
    rescue
      unit = select_active_unit user
      user.active_unit_id = unit.id
    end
    unit
  end
  ##################### END DATA SELECTION METHODS #######################
  
  ##################### CONSTRUCTORS #####################################
  def new_hero user
    unit = Hero.new(user)
    @units[unit.id] = unit
    unit
  end

  def new_random_hero user
    hero = new_hero user
    user.active_unit_id = hero.id
    place_at_random hero
  end

  def new_town_hero user
    empty_cell = empty_adj_cell(get_town(user))
    if empty_cell
      hero = new_hero user
      user.active_unit_id = hero.id
      hero.place empty_cell[:x], empty_cell[:y]
    end
  end

  def new_green_orb
    puts "spawn green orb"
    orb = GreenOrb.new
    @units[orb.id] = orb
    place_at_random orb
  end

  def new_town(user, active_unit_id)
    if @units.select{|k,unit| unit.type == 'Town' && unit.user_id == user.id}.length == 0
      hero = @units[active_unit_id]
      empty_cell = empty_adj_cell hero
      if empty_cell
        town = Town.new(user)
        @units[town.id] = town
        town.place empty_cell[:x], empty_cell[:y]
      end
    end
  end

  def build user, building_id
    town = get_town user
    town.build building_id
  end
  ##################### END CONSTRUCTORS #################################

  # init user
  # If this is a 1st login then new user is created and new hero is placed
  def init_user token
    user = get_user_by_token token
    if user.nil?
      user = User.new(token)
      @users[user.id] = user
      @tokens[token] = user.id
      unit = new_hero user
      user.active_unit_id = unit.id
      place_at_random unit
    end
    # reset ws if connection is dead, user relogged etc
    user
  end

  def move_hero_by user, unit_id, dx, dy
    res = {:log => nil, :moved => false}
    unit = @units[unit_id]
    if unit
      new_x = unit.x + dx
      new_y = unit.y + dy
      if place_is_empty?(new_x, new_y) && @map.has?(new_x, new_y) && @map.d_include?(dx, dy)
        unit.place(new_x, new_y)
        res[:moved] = true
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
      if place_is_empty?(xy[:x], xy[:y])
        unit.place(xy[:x], xy[:y])
        break
      end
    end
  end

  def revive(token)
    user = @users[token]
    unit = user.hero
    if unit.dead?
      @users[unit.user].hero = hero = Hero.new(unit.user)
      place_at_random hero
    end
  end

  def restart(token)
    user = @users[token]
    user.reset_units
  end

  def empty_adj_cell unit
    (-1..1).each do |x|
      (-1..1).each do |y|
        new_x = unit.x + x
        new_y = unit.y + y
        if place_is_empty?(new_x, new_y) && @map.valid?(new_x, new_y)
           return {:x => new_x, :y => new_y}
        end
      end
    end
    nil
  end

  #################### ATTACK #############################################
  def bury(unit)
    @units.delete unit.id
  end

  # a - attacker, {x,y} defender`s coordinates
  # @param [User] a_user attacker
  # @param [Integer] def_id if of the defender unit
  def attack a_user, active_unit_id, def_id
    res = {
      :a_data => {
        :dead => false
      },
      :d_data => {
        :dead => false
      }
    }
    a = get_active_unit a_user
    if a.nil?
      res[:a_data][:log] = 'Your hero is dead'
      return res
    end
    d = @units[def_id]
    dmg = nil
    if d && a != d
      dmg = d.take_dmg a.dmg
      if d.dead?
        bury d
        res[:d_data][:log] = 'Your hero has been killed'
        ca_dmg = 0
      else
        ca_dmg = a.take_dmg d.dmg
        if a.dead?
          bury a
          res[:a_data][:log] = 'Your hero has been killed'
          res[:a_data][:dead] = true
        end
      end
      d_user = @users[d.user_id]
      if d_user
        res[:d_user] = d_user
        res[:d_data].merge!({
                              :data_type => 'dmg',
                              :id => d.id,
                              :dmg => ca_dmg,
                              :ca_dmg => dmg
                            })
      end
    end
    res[:a_data].merge!({:dmg => dmg, :ca_dmg => ca_dmg})
    res
  end
  
end

