# Use specific type of unit subclass (Infantry, Town etc)
# instead of general one (Unit)
# for selecting units of specific type
class Unit
  attr_reader :id, :type, :user, :x, :y, :life, :wounds, :inventory
  attr_accessor :name

  ATTACK_COST = 1
  MAX_LIFE = 15

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
    @defence = 0
    @ap = @max_ap = 0
    @@units[@id] = self
    @life = MAX_LIFE
    @wounds = 0
    @name = nil
    @inventory = {
      :gold => 0,
      :wood => 0,
      :stone => 0,
      :settlers => 0
    }
  end

  def kills
    MAX_LIFE - @life - @wounds
  end

  def kill
    if @life > 0
      @life -= 1
      check_life()
    end
    true
  end

  def wound
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
      'defence' => @defence,
      'inventory' => @inventory,
      'user_name' => @user.login,
      'user_id' => @user.id,
    }
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

  def die
    @dead = true
    place(nil, nil)
  end

  def dmg
    @damage + Random.rand(@damage)
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

  def take_res(res, q)
    unless @inventory.key? res
      @inventory[res] = 0
    end
    # add some checks
    @inventory[res] -= q
  end

  class << self
    def all
      @@units
    end

    def count
      @@units.length
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
      # active ?
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :company}.first
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

  end

end
