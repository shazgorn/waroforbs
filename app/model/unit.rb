# Use specific type of unit subclass (Infantry, Town etc)
# instead of general one (Unit)
# for selecting units of specific type
class Unit
  attr_reader :id, :type, :user, :x, :y, :life

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
    @hp = @max_hp = 1
    @@units[@id] = self
    @life = MAX_LIFE
    @wounds = 0
  end

  def kills
    MAX_LIFE - @life - @wounds
  end

  def kill
    if @life > 0
      @life -= 1
      check_life()
    end
  end

  def wound
    if @life > 0
      @life -= 1
      @wounds += 1
      check_life()
    end
  end

  def check_life()
    if @life == 0
      die
    end
  end

  def to_hash()
    hash = {}
    self.instance_variables.each do |var|
      if var == :@user
        if @user
          hash[:@user_name] = @user.login
          hash[:@user_id] = @user.id
        end
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
    reduced_dmg = income_dmg - @defence
    reduced_dmg = 1 if reduced_dmg < 1
    @hp -= reduced_dmg
    if @hp <= 0
      die
    end
    reduced_dmg
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
      puts "Unit.get is deprecated"
      get_by_id id
    end

    ##
    # select and return object of Unit class with +id+
    # return nil if unit is not found

    def get_by_id id
      @@units[id]
    end

    def get_by_user_id user, id
      unit = @@units[id]
      return unit if unit.user && unit.user_id == user.id
    end

    def delete id
      @@units.delete id
    end

    def select_active_unit user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :company}.first
    end

    def place_is_empty?(x, y)
      @@units.select{|k, unit| unit.x == x && unit.y == y}.length == 0
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
