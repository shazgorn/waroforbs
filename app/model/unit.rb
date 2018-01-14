# Use specific type of unit subclass
# instead of general one (Unit)
# for selecting units of specific type
class Unit
  attr_reader :id, :type, :user, :x, :y, :life, :wounds, :inventory, :attack, :defence, :initiative, :created_time, :spotting_range
  attr_accessor :name

  ATTACK_COST = 1

  @@id_seq = 1
  # id -> unit
  @@units = {}

  # @user User
  # change user_id to user
  def initialize(type, x, y, user = nil)
    @id = @@id_seq
    @@id_seq += 1
    @type = type
    @user = user
    @dead = false
    @x = x
    @y = y
    if Config[type]
      @attack = Config[type][:attack].to_i
      @defence = Config[type][:defence].to_i
      @initiative = Config[type][:initiative].to_i
      @ap = @max_ap = Config[type][:ap].to_i
      @life = Config[:max_life]
    else
      @attack = @defence = @initiative = @ap = @max_ap = @life = 0
    end
    @wounds = 0
    @name = nil
    @spotting_range = 7 # spotting range will be moved to config later, towns a with Watch Tower building should have increased spotting range, and town itself should be visible from afar
    @in_battle = false
    @inventory = {
      :gold => 0,
      :wood => 0,
      :stone => 0,
      :settlers => 0
    }
    @created_time = Time.now
    @@units[@id] = self
  end

  def strength
    @life
  end

  def kills
    Config.get(:max_life) - @life - @wounds
  end

  def kill
    @in_battle = true
    if @life > 0
      @life -= 1
      check_life()
    end
    true
  end

  def wound
    @in_battle = true
    if @life > 0
      @life -= 1
      @wounds += 1
      check_life()
    end
    true
  end

  def check_life()
    if @life == 0
      die
    end
  end

  def to_hash()
    {
      'id' => @id,
      'type' => @type,
      'name' => @name,
      'x' => @x,
      'y' => @y,
      'ap' => @ap,
      'life' => @life,
      'wounds' => @wounds,
      'dead' => @dead,
      'attack' => @attack,
      'defence' => @defence,
      'spotting_range' => @spotting_range,
      'inventory' => @inventory,
      'user_name' => @user ? @user.login : nil,
      'user_id' => @user ? @user.id : nil,
    }
  end

  def to_enemy_hash
    {
      'id' => @id,
      'type' => @type,
      'name' => @name,
      'x' => @x,
      'y' => @y,
      'life' => @life,
      'dead' => @dead,
      'user_name' => @user ? @user.login : nil,
      'user_id' => @user ? @user.id : nil,
    }
  end

  def user_id
    if @user
      @user.id
    else
      nil
    end
  end

  def spotted? unit
    (@x - @spotting_range..@x + @spotting_range).include?(unit.x) && (@y - @spotting_range..@y + @spotting_range).include?(unit.y)
  end

  def dead?
    @dead
  end

  def alive?
    !dead?
  end

  def die
    @dead = true
    place(nil, nil)
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

  alias can_attack? can_move?

  ##
  # If +unit+ can enter into +self+

  def enterable_for(unit)
    false
  end

  def not_enterable_for(unit)
    !enterable_for(unit)
  end

  def move(cost)
    if @ap >= cost
      @ap -= cost
    end
  end

  # game loop function called every `n` seconds
  def tick
    restore_ap
  end

  # restore some amount of @ap per tick
  def restore_ap
    if @ap <= @max_ap - 1
      @ap += 1
    end
  end

  def give_res(res, q)
    unless @inventory.key? res
      @inventory[res] = 0
    end
    @inventory[res] += q
  end

  ##
  # Return quantity of take resources

  def take_res(res, q)
    unless @inventory.key? res
      @inventory[res] = 0
    end
    if q > @inventory[res]
      taken_q = @inventory[res]
      @inventory[res] = 0
      return taken_q
    end
    @inventory[res] -= q
    q
  end

  ##
  # Check if two units are enemies (not allies, clan members, own)
  # Neutral units(resources) are not enemies

  def enemy_of? unit
    if unit.user_id
      user_id != unit.user_id
    end
  end

  class << self
    def all
      @@units
    end

    ##
    # select and return object of Unit class with +id+
    # return nil if unit is not found

    def get_by_id id
      @@units[id]
    end

    ##
    # Get units for user

    def get_by_user(user)
      @@units.values.select{|unit| unit.user_id == user.id}
    end

    ##
    # Get units for user with keys

    def get_by_user_h user
      @@units.select{|id, unit| unit.user_id == user.id}
    end

    def get_by_user_id user, id
      unit = @@units[id]
      return unit if unit && unit.user && unit.user_id == user.id
      nil
    end

    def delete(id)
      @@units.delete(id)
    end

    def delete_by_user(user)
      get_by_user(user).each {|unit|
        delete(unit.id)
      }
    end

    def select_active_unit user
      @@units.values.select{|unit| unit.user_id == user.id}.first
    end

    def place_is_empty?(x, y)
      @@units.select{|k, unit| unit.x == x && unit.y == y && unit.alive?}.length == 0
    end

    def get_by_xy(x, y)
      @@units.values.select{|unit| unit.x == x && unit.y == y}.first
    end

    def has_units? user
      @@units.values.select{|unit| unit.user_id == user.id}.length > 0
    end

    def has_live_units? user
      @@units.values.select{|unit| unit.user_id == user.id && unit.alive?}.length > 0
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

    def drop_all
      @@units = {}
    end

    def get_by_type type
      @@units.select{|id, unit| unit.type == type}
    end

    def get_by_types types
      @@units.select{|id, unit| types.include? unit.type}
    end

    def each_alive
      @@units.each{|id, unit| yield id, unit if unit.alive?}
    end
  end
end
