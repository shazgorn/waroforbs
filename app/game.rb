require 'log_entry'
require 'log_box'
require 'orb'
require 'unit'
require 'expirable'
require 'chest'
require 'resource'
require 'swordsman'
require 'elf_swordsman'
require 'hero_swordsman'
require 'town'
require 'monolith'
require 'map'
require 'user'
require 'building'
require 'tavern'
require 'barracs'
require 'roads'
require 'factory'
require 'sawmill'
require 'quarry'
require 'cli'
require 'squad_attack'
require 'attack'
require 'token'
require 'turn_counter'
require 'town_aid'
require 'elf_spawner'

##
# Game logic, some kind of incubator
# code from here will be moved to more appropriate places
# like data storage, attack strategy etc
# dead heroes are dead if they never exists
# should move unit creation methods to separate class

class Game
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger
  include Cli

  def initialize()
    info 'Starting game'
    @generate = false
    check_args
    subscribe('tick', :tick)
    subscribe('spawn_random_res_near', :spawn_random_res_near)
  end

  ############ DATA SELECTION METHODS ########################
  def get_user_by_token(token)
    Token.get_user(token)
  end

  def get_current_logs_by_user(user)
    LogBox.get_current_by_user(user)
  end

  ##
  # Select and return all units for user

  def all_units_for_user(user)
    my = Unit.get_by_user_h(user)
    visible = {}
    visible.merge! my
    my.each do |id, my_unit|
      Unit.each_alive do |id, unit|
        visible[id] = unit if my_unit.spotted? unit
      end
    end
    visible
  end

  def dump
    info "Dump data"
    ts = Time.now.strftime "%Y_%m_%d_%H_%M_%S"
    [User, Unit].each{|cls|
      path = "data/" + cls.to_s + '_' + ts + '.dat'
      File.open(path, "w") do |file|
        file.print Marshal.dump(cls.all)
        info cls.to_s + " data saved to %s" % path
      end
    }
  end

  ##################### DATA MODIFICATION METHODS  #######################
  ##
  # disband - delete unit like it never exists
  # +user+ User
  # +unit_id+ int

  def disband(user, unit_id)
    unit = Unit.get_by_user_id(user, unit_id)
    user.active_unit_id = nil
    return LogBox.error(I18n.t('log_entry_no_unit_to_disband'), user) unless unit
    Unit.delete(unit.id)
    LogBox.spawn(I18n.t('log_entry_unit_disbanded', unit_id: unit_id), user)
  end

  def rename_unit(user, unit_id, unit_name)
    unit = Unit.get_by_user_id(user, unit_id)
    old_name = unit.name
    unit.name = unit_name
    LogBox.spawn(I18n.t('log_entry_unit_renamed', old_name: old_name, new_name: unit_name), user)
  end

  ##################### CONSTRUCTORS #####################################

  ## init user
  # If this is a 1st login then new user is created
  # and new hero is placed
  # Do not return log_entry because or mulitple logs???
  # return user

  def init_user(token)
    user = get_user_by_token(token)
    if user.nil?
      user = User.new(token)
      LogBox.spawn(I18n.t('log_entry_new_user', user: user.login), user)
      Token.set(token, user)
      start_res_for_user(user)
    else
      LogBox.spawn(I18n.t('log_entry_user_logged_in', user: user.login), user)
    end
    user
  end

  def restart(user)
    Unit.delete_by_user(user)
    start_res_for_user(user)
    user.reset_glory
  end

  ##
  # Give starting resources to the +user+
  # after +user+ init or restart

  def start_res_for_user(user)
    unit = new_random_squad(user)
    Config[:start_res].each{|res, q|
      unit.give_res(res, q)
    }
  end

  ##
  # user must be initialized

  def init_map(token)
    user = get_user_by_token(token)
    {
      :map_shift => Map::SHIFT,
      :cell_dim_in_px => Map::CELL_DIM_PX,
      :block_dim_in_cells => Actor[:map].block_dim,
      :block_dim_in_px => Actor[:map].block_dim_px,
      :map_dim_in_blocks => Actor[:map].blocks_in_map_dim,
      :MAX_CELL_IDX => Actor[:map].max_cell_idx,
      :active_unit_id => user.active_unit_id,
      :user_id => user.id,
      :user_name => user.login,
      :user_glory => user.glory,
      :user_max_glory => user.max_glory,
      :actions => user.actions,
      :units => all_units_for_user(user),
      :cells => Actor[:map].tiles,
      :blocks => Actor[:map].blocks,
      :logs => LogBox.get_by_user(user),
      :resource_info => {
        :gold => {
          :title => I18n.t('res_gold_title'),
          :description => I18n.t('res_gold_description'),
          :action => false
        },
        :wood => {
          :title => I18n.t('res_wood_title'),
          :description => I18n.t('res_wood_description'),
          :action => false
        },
        :stone => {
          :title => I18n.t('res_stone_title'),
          :description => I18n.t('res_stone_description'),
          :action => false
        },
        :settlers => {
          :title => I18n.t('res_settlers_title'),
          :description => I18n.t('res_settlers_description'),
          :action => true,
          :action_label => I18n.t('res_settlers_action_label')
        }
      },
      :building_states => {
        :BUILDING_STATE_GROUND => Building::STATE_GROUND,
        :BUILDING_STATE_IN_PROGRESS => Building::STATE_IN_PROGRESS,
        :BUILDING_STATE_COMPLETE => Building::STATE_COMPLETE,
        :BUILDING_STATE_CAN_UPGRADE => Building::STATE_CAN_UPGRADE
      },
      :building_descriptions => I18n.t('BuildingDescriptions')
    }
  end

  ##
  # Create new random squad unit for user if it`s his first login
  # or all other units and towns are destroyed
  # raise OrbError otherwise

  def new_random_squad(user)
    raise OrbError, 'User have some live units' if Unit.has_live_units? user
    xy = get_random_xy
    LogBox.spawn(I18n.t('log_entry_no_empty_cells'), user) unless xy
    unit = Swordsman.new(xy[:x], xy[:y], user)
    LogBox.spawn(I18n.t('log_entry_new_unit', name: unit.name), user)
    user.active_unit_id = unit.id
    unit
  end

  ##
  # +user+ User
  # +unit_type+ String

  def hire_unit(user, unit_type)
    town = Town.get_by_user(user)
    unless Config[:unit_class][unit_type]
      LogBox.error(I18n.t('log_entry_unknown_unit', unit_type: unit_type), user)
      return
    end
    if town.nil?
      LogBox.error(I18n.t('log_entry_user_has_no_town'), user)
      return
    end
    Config[unit_type][:required_buildings].each{|building|
      unless town.built?(building)
        LogBox.error(I18n.t('log_entry_building_not_build', building: I18n.t(building.capitalize)), user)
        return
      end
    }
    if user.glory < Config.get(unit_type)[:cost_glory]
      LogBox.error(I18n.t('log_entry_more_glory_required'), user)
      return
    end
    cost = Config.get(unit_type)[:cost_res]
    if res = town.check_price(cost)
      LogBox.error(res, user)
      return
    end
    empty_cell = empty_adj_cell(town)
    unless empty_cell
      LogBox.error(I18n.t("log_entry_no_free_cells"), user)
      return
    end
    town.pay_price(cost)
    user.pay_glory(Config[unit_type][:cost_glory])
    unit = Module.const_get(Config[:unit_class][unit_type]).new(empty_cell[:x], empty_cell[:y], user)
    user.active_unit_id = unit.id
    LogBox.spawn(I18n.t("log_entry_new_unit", name: unit.name), user)
    unit
  end

  # def refill_squad(user, town_id, unit_id)
  #   town = Town.get_by_user(user)
  #   raise OrbError, 'User have no town' if town.nil?
  #   if town.can_fill_squad?
  #     unit = Squad.get unit_id
  #     raise OrbError, 'No unit' unless unit
  #     raise OrbError, 'Unit must be near town' unless Actor[:map].adj_cells?(town.x, town.y, unit.x, unit.y)
  #     town.pay_squad_price()
  #   end
  # end

  # TODO: check that active unit have settlers
  def settle_town(user, active_unit_id)
    return LogBox.error(I18n.t('log_entry_already_have_town'), user) if Town.has_live_town? user
    unit = Unit.get_by_id(active_unit_id)
    raise OrbError, "Active unit is nil" unless unit
    town = Town.new(unit.x, unit.y, user)
    TownAid.new(town).async.run
    unit.take_res(:settlers, 1)
    LogBox.spawn(I18n.t('log_entry_settle_town'), user)
  end

  ##################### TOWN / BUILDINGS ACTIONS #################################
  def build(user, building_id)
    town = Town.get_by_user user
    return LogBox.error(I18n.t('log_entry_user_has_no_town'), user) if town.nil?
    begin
      if town.build(building_id)
        LogBox.spawn(I18n.t('log_entry_construction_started', building: town.get_building_title(building_id)), user)
      end
    rescue UnableToComplyBuildingInProgress
      LogBox.error(I18n.t('log_entry_building_already_in_progress'), user)
    rescue NotEnoughResources
      LogBox.error(I18n.t('log_entry_not_enough_res', res: ''), user)
    rescue MaxBuildingLevelReached
      LogBox.error(I18n.t('log_entry_max_building_level_reached', res: ''), user)
    end
  end

  def set_worker_to_xy(user, town_id, worker_pos, x, y)
    town = Town.get_by_user user
    raise OrbError, 'No user town' unless town
    raise OrbError, 'You are trying to set worker at town coordinates' if town.x == x && town.y == y
    raise OrbError, 'Cell is not near town' unless town.in_radius?(x, y)
    type = Config[:terrain_to_res][Actor[:map].cell_type_at(x, y)]
    raise OrbError, "No resource type for map tile #{x}, #{y}" if type.nil?
    town.set_worker_to(worker_pos, x, y, type)
  end

  ##
  # unit - Unit
  # dx - int
  # dy - int

  def move_unit_by(unit, dx, dy)
    return LogBox.error(I18n.t('log_entry_wrong_direction'), unit.user) unless Actor[:map].d_include?(dx, dy)
    return LogBox.error(I18n.t('log_entry_unit_dead'), unit.user) if unit.dead?
    new_x = unit.x + dx
    new_y = unit.y + dy
    return LogBox.error(I18n.t('log_entry_out_of_map'), unit.user) unless Actor[:map].has?(new_x, new_y)
    type = Actor[:map].cell_type_at(new_x, new_y)
    cost = Config[:terrain_move_cost][type].to_i
    return LogBox.error(I18n.t('log_entry_not_enough_ap'), unit.user) unless unit.can_move?(cost)
    u = Unit.get_by_xy(new_x, new_y)
    if u && u.alive? && u.not_enterable_for(unit)
      return LogBox.error(I18n.t('log_entry_cell_occupied'), unit.user)
    end
    if enemy_zoc2zoc? unit, new_x, new_y
      return LogBox.error(I18n.t('log_entry_enemy_zoc'), unit.user)
    end
    unit.move_to(new_x, new_y, cost)
    LogBox.move(unit.id, dx, dy, new_x, new_y, unit.user)
  end

  ##
  # Check if unit is trying to move from Zone of Control of one enemy to Zone of Control of another enemy or the first one
  def enemy_zoc2zoc? a, x2, y2
    enemy_zoc?(a, a.x, a.y) && enemy_zoc?(a, x2, y2)
  end

  ##
  # Return true if enemy unit is adj to x, y, false otherwise

  def enemy_zoc? unit, x, y
    (Actor[:map].axis_range_adj y).each do |adj_y|
      (Actor[:map].axis_range_adj x).each do |adj_x|
        adj_unit = Unit.get_by_xy adj_x, adj_y
        if adj_unit && unit.enemy_of?(adj_unit)
          return true
        end
      end
    end
    false
  end

  ##
  # user - User
  # unit_id - int
  # dx - int
  # dy - int
  # Select unit by id and move it
  # return log_entry

  def move_user_hero_by(user, unit_id, dx, dy)
    unit = Unit.get_by_id(unit_id)
    return LogBox.error(I18n.t('log_entry_unit_not_found', unit_id: unit_id), user) unless unit
    move_unit_by(unit, dx, dy)
  end

  ##
  # Res can be given to any unit, not our own
  # TODO: narrow(make) the list of allowed recipients

  def give(user, from_id, to_id, inventory)
    from = Unit.get_by_user_id(user, from_id)
    to = Unit.get_by_id(to_id)
    inventory.each{|res, q|
      taken_q = from.take_res(res.to_sym, q.to_i)
      to.give_res(res.to_sym, taken_q)
    }
    # TODO: log
  end

  ##
  # Res can be take to any own unit but from any
  # TODO: narrow(make) the list of allowed donors(own, neutral)

  def take(user, to_id, from_id, inventory)
    to = Unit.get_by_user_id(user, to_id)
    from = Unit.get_by_id(from_id)
    inventory.each{|res, q|
      taken_q = from.take_res(res.to_sym, q.to_i)
      to.give_res(res.to_sym, taken_q)
    }
    # TODO: log
  end

  ##
  # Get random coordinates not occupied by any unit
  # return {:x => x, :y => y}

  def get_random_xy
    10000.times do
      xy = Actor[:map].get_rand_coords
      if Unit.place_is_empty?(xy[:x], xy[:y])
        return xy
      end
    end
    return nil
  end

  ##
  # return first empty cell coordinates adjacent to +x+,+y+

  def empty_adj_cell_xy(x, y)
    range = (-1..1)
    range.each do |dx|
      range.each do |dy|
        new_x = x + dx
        new_y = y + dy
        if Unit.place_is_empty?(new_x, new_y) && Actor[:map].valid?(new_x, new_y)
          return {:x => new_x, :y => new_y}
        end
      end
    end
    nil
  end

  def empty_adj_cell(unit, radius = 1)
    empty_adj_cell_xy(unit.x, unit.y)
  end

  def tick(topic)
    User.all.values.each{|user|
      user.tick
    }
    Unit.all.values.each{|unit|
      unit.tick
    }
  end

  def expire_by_class cls
    cls.all.each{|id, res|
      if res.expired?
        cls.delete res.id
      end
    }
  end

  def check_expired
    expire_by_class Resource
    expire_by_class Chest
  end

  def spawn_random_res_near topic, town, class_to_spawn
    check_expired
    xy = Actor[:map].get_rand_coords_near town.x, town.y, Config[:random_res_town_radius]
    if Unit.place_is_empty?(xy[:x], xy[:y])
      class_to_spawn.new(xy[:x], xy[:y])
      return true
    end
    false
  end

  def black_orbs_below_limit
    BlackOrb.below_limit?
  end

  def spawn_dummy_near(x, y)
    user = User.new(Config.get('DUMMY_LOGIN'))
    xy = empty_adj_cell_xy(x, y)
    if xy
      Swordsman.new(xy[:x], xy[:y], user)
    else
      LogBox.error(I18n.t('log_entry_no_empty_cells'), user)
    end
  end

  def provoke_dummy_attack()
    user = User.new(Config.get('DUMMY_LOGIN'))
    units = Unit.get_by_user(user)
    units.each{|unit|
      attack_adj_cells(unit)
    }
  end

  def spawn_monolith_near(x, y)
    user = User.new(Config.get('DUMMY_LOGIN'))
    xy = empty_adj_cell_xy(x, y)
    if xy
      Monolith.new(xy[:x], xy[:y], user)
    else
      LogBox.error(I18n.t('log_entry_no_empty_cells'), user)
    end
  end

  def spawn_orb color
    case color
    when :black
      log_entry = spawn_black_orb
    when :green
      log_entry = spawn_green_orb
    else
      log_entry = LogEntry.error 'Unknown orb type'
    end
    log_entry
  end

  ##
  # merge into one func

  def spawn_black_orb
    return LogEntry.error 'Too many black orbs' unless BlackOrb.below_limit?
    xy = get_random_xy
    BlackOrb.new xy[:x], xy[:y]
    info "Spawned black orb (%d)" % BlackOrb.length
    LogEntry.spawn 'Black orb has been spawned'
  end

  def spawn_green_orb
    return LogEntry.error 'Too many green orbs' unless GreenOrb.below_limit?
    xy = get_random_xy
    GreenOrb.new xy[:x], xy[:y]
    info "Spawned green orb (%d)" % GreenOrb.length
    LogEntry.spawn 'Green orb has been spawned'
  end

  #################### ATTACK ##################################################
  ##
  # a +Unit+

  def attack_adj_cells a
    (-1..1).each do |adx|
      (-1..1).each do |ady|
        if !(adx == 0 && ady == 0)
          adj_x = a.x + adx
          adj_y = a.y + ady
          d = Unit.get_by_xy(adj_x, adj_y)
          if d
            return attack(a, d)
          end
        end
      end
    end
    nil
  end

  ##
  # a - attacker unit, d - defender unit

  def attack(a, d)
    res = SquadAttack.new(a, d).attack
    LogBox.attack(res, a.user)
    if d.user
      LogBox.defence(res, d.user)
    end
    res
  end

  ##
  # Attack unit by user
  # @param [User] a_user attacker
  # @param [Integer] def_id if of the defender unit

  def attack_by_user(a_user, a_id, def_id)
    a = Unit.get_by_id(a_id)
    if a.nil? || a.user != a_user
      LogBox.error(I18n.t('log_entry_wrong_attacker_id'), a_user)
      return nil
    end
    d = Unit.get_by_id(def_id)
    unless a.can_attack?(Unit::ATTACK_COST)
      LogBox.error(I18n.t('log_entry_not_enough_ap'), a_user)
      return nil
    end
    if d.nil?
      LogBox.error(I18n.t('log_entry_defender_not_found'), a_user)
      return nil
    end
    if d.dead?
      LogBox.error(I18n.t('log_entry_defender_already_dead'), a_user)
      return nil
    end
    attack(a, d)
  end
end
