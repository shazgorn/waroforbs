# Game logic, some kind of incubator
# code from here will be moved to more appropriate places
# like data storage, attack strategy etc
# dead heroes are dead if they never exists
class Game
  attr_reader :map

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
  def new_hero user
    Hero.new(user)
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

  def new_town(user, active_unit_id)
    unless Town.user_has_town? user
      hero = Hero.get active_unit_id
      empty_cell = empty_adj_cell hero
      if empty_cell
        town = Town.new(user)
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
      @tokens[token] = user.id
      unit = new_hero user
      user.active_unit_id = unit.id
      place_at_random unit
    end
    user
  end

  def move_hero_by user, unit_id, dx, dy
    res = {:log => nil, :moved => false}
    unit = Unit.get unit_id
    if unit
      new_x = unit.x + dx
      new_y = unit.y + dy
      if Unit.place_is_empty?(new_x, new_y) && @map.has?(new_x, new_y) && @map.d_include?(dx, dy)
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
      if Unit.place_is_empty?(xy[:x], xy[:y])
        unit.place(xy[:x], xy[:y])
        break
      end
    end
  end

  def revive(token)
  end

  def restart(token)
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

  #################### ATTACK #############################################
  def bury(unit)
    Unit.delete unit.id
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
    a = Unit.get_active_unit a_user
    if a.nil?
      res[:a_data][:log] = 'Your hero is dead'
      return res
    end
    d = Unit.get def_id
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
      d_user = User.get d.user_id
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

