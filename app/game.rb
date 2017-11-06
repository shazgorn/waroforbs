require 'log_entry'
require 'log_box'
require 'orb'
require 'unit'
require 'heavy_infantry'
require 'town'
require 'map'
require 'user'
require 'building'
require 'cli'
require 'squad_attack'
require 'attack'
require 'token'

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

  attr_reader :map

  def initialize(drop = false)
    info 'Starting game'
    @generate = false
    check_args
    @map = Map.new(@generate)
    drop_all if drop
    subscribe('tick', :tick)
  end

  def drop_all
    Unit.drop_all
    User.drop_all
  end

  ############ DATA SELECTION METHODS ########################
  def get_user_by_token(token)
    Token.get_user(token)
  end

  def get_current_logs_by_user(user)
    LogBox.get_current_by_user(user)
  end

  def all_units_for_all units
    units.each_value{|unit|
      if unit.type == :town
        unit.adj_companies = []
        units.each_value{|adj_unit|
          if adj_unit.alive? && unit != adj_unit && unit.user && unit.user == adj_unit.user && @map.adj_cells?(unit.x, unit.y, adj_unit.x, adj_unit.y)
            unit.adj_companies.push(adj_unit.id)
          end
        }
      end
    }
  end

  ##
  # Select and return all units.
  # Select user`s town and select adjacent companies to it (one can add more
  # squads in barracs)
  # TODO: calc adj companies only on company move, dead, new town

  def all_units(token)
    units = Unit.all
    if false
      users.each{|id, data|
        user = User.get(id)
        if user
          town = units.values.select{|unit| unit.type == :town && unit.user.id == user.id}.first
          if town && town.alive?
            town.adj_companies = []
            units.each_value{|unit|
              if unit.alive? && unit != town && unit.user && unit.user.id == user.id && @map.adj_cells?(town.x, town.y, unit.x, unit.y)
                town.adj_companies.push(unit.id)
              end
            }
          end
        end
      }
    else
      all_units_for_all units
    end
    units
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
  def dismiss user, id
    unit = Unit.get_by_user_id user, id
    raise OrbError, "No unit to dismiss" unless unit
    unit.die
    recalculate_user_actions user
  end

  def bury(unit)
    if unit.user
      recalculate_user_actions(unit.user)
    end
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
      unit = new_random_infantry(user)
      unit.give_res(:settlers, 1)
      unit.give_res(:gold, 10)
      unit.give_res(:wood, 7)
    else
      LogBox.spawn(I18n.t('log_entry_user_logged_in', user: user.login), user)
    end
    user
  end

  def init_map(token)
    user = get_user_by_token(token)
    {
      :map_shift => Map::SHIFT,
      :cell_dim_in_px => Map::CELL_DIM_PX,
      :block_dim_in_cells => Map::BLOCK_DIM,
      :block_dim_in_px => Map::BLOCK_DIM_PX,
      :map_dim_in_blocks => Map::BLOCKS_IN_MAP_DIM,
      :MAX_CELL_IDX => Map::MAX_CELL_IDX,
      :active_unit_id => user.active_unit_id,
      :user_id => user.id,
      :actions => user.actions,
      :units => all_units({user.id => {}}),
      :cells => @map.cells,
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
      :TOWN_RADIUS => Town::RADIUS,
      :building_states => {
        :BUILDING_STATE_CAN_BE_BUILT => Building::STATE_CAN_BE_BUILT,
        :BUILDING_STATE_IN_PROGRESS => Building::STATE_IN_PROGRESS,
        :BUILDING_STATE_BUILT => Building::STATE_BUILT
      }
    }
  end

  ##
  # Create new random infantry unit for user if it`s his first login
  # or all other units and towns are destroyed
  # raise OrbError otherwise

  def new_random_infantry(user)
    raise OrbError, 'User have some live units' if Unit.has_live_units? user
    xy = get_random_xy
    unit = HeavyInfantry.new(xy[:x], xy[:y], user)
    LogBox.spawn(I18n.t('log_entry_new_infantry'), user)
    user.active_unit_id = unit.id
    recalculate_user_actions(user)
    unit
  end

  def create_company(user)
    town = Town.get_by_user(user)
    LogBox.error(I18n.t('log_entry_user_has_no_town'), user) if town.nil?
    unless town.has_build_barracs?
      LogBox.error(I18n.t('log_entry_barracs_not_build'), user)
      return
    end
    if HeavyInfantry.count(user) > Config.get('HEAVY_INFANTRY_LIMIT')
      LogBox.error(I18n.t('log_entry_company_limit_reached', limit: Config.get('HEAVY_INFANTRY_LIMIT')), user)
      return
    end
    unless town.check_company_price
      LogBox.error(I18n.t('log_entry_company_not_enough_res'), user)
      return
    end
    empty_cell = empty_adj_cell(town)
    unless empty_cell
      LogBox.error(I18n.t("log_entry_company_no_free_cells"), user)
      return
    end
    town.pay_company_price
    company = HeavyInfantry.new(empty_cell[:x], empty_cell[:y], user)
    user.active_unit_id = company.id
    LogBox.spawn(I18n.t("log_entry_new_infantry"), user)
    company
  end

  # def add_life_to_squad(user, town_id, squad_id)
  #   town = Town.get_by_user(user)
  #   raise OrbError, 'User have no town' if town.nil?
  #   if town.can_fill_squad?
  #     infantry = Infantry.get company_id
  #     raise OrbError, 'No company' unless infantry
  #     raise OrbError, 'Infantry must be near town' unless @map.adj_cells?(town.x, town.y, infantry.x, infantry.y)
  #     town.pay_squad_price()
  #     infantry.add_squad()
  #   end
  # end

  def settle_town(user, active_unit_id)
    # replace with action check ?
    return LogBox.error(I18n.t('log_entry_already_have_town'), user) if Town.has_live_town? user
    info "User have no town"
    unit = HeavyInfantry.get_by_id(active_unit_id)
    raise OrbError, "Active unit is nil" unless unit
    Town.new(unit.x, unit.y, user)
    recalculate_user_actions user
    unit.take_res(:settlers, 1)
    LogBox.spawn(I18n.t('log_entry_settle_town'), user)
  end

  ##################### TOWN / BUILDINGS ACTIONS #################################
  def build(user, building_id)
    town = Town.get_by_user user
    return LogBox.error(I18n.t('log_entry_user_has_no_town'), user) if town.nil?
    town.build(building_id)
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

  TYPE2COST = {
    :grass => 1,
    :tree => 2,
    :mountain => 3
  }

  ##
  # unit - Unit
  # dx - int
  # dy - int

  def move_unit_by(unit, dx, dy)
    return LogEntry.error(I18n.t('log_entry_unit_not_found', unit_id: unit_id)) unless unit
    return LogEntry.error(I18n.t('log_entry_wrong_direction')) unless @map.d_include?(dx, dy)
    return LogEntry.error(I18n.t('log_entry_unit_dead')) if unit.dead?
    new_x = unit.x + dx
    new_y = unit.y + dy
    return LogEntry.error(I18n.t('log_entry_out_of_map')) unless @map.has?(new_x, new_y)
    type = @map.cell_type_at(new_x, new_y)
    cost = TYPE2COST[type]
    return LogEntry.error(I18n.t('log_entry_not_enough_ap')) unless unit.can_move?(cost)
    return LogEntry.error(I18n.t('log_entry_cell_occupied')) unless Unit.place_is_empty?(new_x, new_y)
    unit.move_to(new_x, new_y, cost)
    LogBox.move(unit.id, dx, dy, new_x, new_y, unit.user)
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
    move_unit_by(unit, dx, dy)
  end

  def random_move(unit)
    dx = dy = 0
    begin
      dx = Random.rand(-1..1)
      dy = Random.rand(-1..1)
    end while (dx == 0 && dy == 0) || !@map.has?(unit.x + dx, unit.y + dy)
    info "random move ##{unit.id} (#{unit.type}) by #{dx}, #{dy}"
    move_unit_by(unit, dx, dy)
  end

  ##
  # Get random coordinates not occupied by any unit
  # return {:x => x, :y => y}

  def get_random_xy
    while true
      xy = @map.get_rand_coords
      if Unit.place_is_empty?(xy[:x], xy[:y])
        return xy
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

  def restart(token)
  end

  def tick(topic)
    Unit.all.values.each{|unit|
      unit.tick
    }
  end

  def black_orbs_below_limit
    BlackOrb.below_limit?
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

  ##
  # a - attacker unit, d - defender unit

  def attack(a, d)
    return raise OrbError, 'Not enough ap to attack' unless a.can_move?(Unit::ATTACK_COST)
    res = SquadAttack.attack(a, d)
    if a.dead?
      bury(a)
    end
    if d.dead?
      bury(d)
    end
    res
  end

  ##
  # Attack unit by user
  # @param [User] a_user attacker
  # @param [Integer] def_id if of the defender unit

  def attack_by_user(a_user, a_id, def_id)
    a = Unit.get_by_id(a_id)
    return {:error => 'Wrong attacker id'} if a.nil? || a.user != a_user
    d = Unit.get_by_id(def_id)
    return {:error => 'Defender not found'} if d.nil?
    return {:error => 'Defender is already dead'} if d.dead?
    attack(a, d)
  end

  def recalculate_user_actions user
    has_town = Town.has_any? user
    has_live_company = HeavyInfantry.has_any_live? user
    if has_live_company && !has_town
      user.enable_new_town_action
    elsif !has_live_company && !has_town
      user.enable_new_random_infantry_action
    else
      user.disable_new_random_infantry_action
      user.disable_new_town_action
    end
  end

end


##
# Set defender`s data from +res+ in +users+
# +res+ is a result of the +attack+ execution
# +users+ hash of attacking and defending users

def set_def_data users, res
  if res.has_key?(:d_user) && res[:d_user]
    if user_online?(res[:d_user])
      users[res[:d_user].id] = res[:d_data]
      users[res[:d_user].id][:log] = log_entry
    end
  end
end

def save_and_exit
  info "Terminating..."
  dump
  info "Good bye!"
  exit
end
