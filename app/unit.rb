# Use specific type of unit subclass (Company, Town etc)
# instead of general one (Unit)
# for selecting units of specific type
class Unit
  attr_reader :id, :type, :user, :x, :y

  @@id_seq = 1
  # id -> unit
  @@units = {}

  # @user User
  # change user_id to user
  def initialize(type, user = nil)
    @id = @@id_seq
    @@id_seq += 1
    @type = type
    @user = user
    @dead = false
    @x = nil
    @y = nil
    @ap = @max_ap = 0
    @hp = @max_hp = 1
    @@units[@id] = self
  end

  def to_hash()
    hash = {}
    self.instance_variables.each do |var|
      if var == :@user
        if @user
          hash[:@user_name] = @user.login
          hash[:@user_id] = @user.id
        end
      elsif var == :@banner
        # id?
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

  def take_dmg(dmg)
    @hp -= dmg
    if @hp <= 0
      @dead = true
    end
    dmg
  end

  def die
    @dead = true
  end

  def dmg
    @dmg + Random.rand(@dmg)
  end

  def place(x = nil, y = nil)
    @x = x
    @y = y
  end

  def move_to(x, y)
    place(x, y)
    @ap -= 1
  end

  def can_move?
    @ap >= 1
  end

  def move
    if @ap >= 1
      @ap -= 1
    end
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
      @@units[id]
    end

    def delete id
      @@units.delete id
    end

    def select_active_unit user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :company}.first
    end

    def place_is_empty?(x, y)
      @@units.select{|k,unit| unit.x == x && unit.y == y}.length == 0
    end

    def get_by_user user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :town}.first
    end

    def has_town? user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :town}.length == 1
    end    

    def has_heroes? user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :company}.length > 0
    end

    def has_units? user
      @@units.values.select{|unit| unit.user_id == user.id}.length > 0
    end

    def all_units_count user
      @@units.values.select{|unit| unit.user_id == user.id}.length
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
    
  end

end

class Company < Unit
  MAX_SQUADS = 10
  BASE_DMG = 30
  BASE_HP = 50
  BASE_AP = 20

  def initialize(user, banner)
    super(:company, user)
    @banner = banner
    @banner.unit = self
    @dmg = (BASE_DMG * banner.mod_dmg).round(0)
    # @hp - hp of 1st squad in line
    @hp = @max_hp = (BASE_HP * banner.mod_max_hp).round(0)
    @ap = @max_ap = (BASE_AP * banner.mod_max_ap).round(0)
    # each company starts with one squad
    @squads = 1
  end

  def die
    super
    @banner.unit = nil
  end

  def add_squad
    if @squads < MAX_SQUADS
      @squads += 1
    end
  end

  def take_dmg(dmg)
    total_hp = @max_hp * (@squads - 1) + @hp
    total_hp -= dmg
    if total_hp <= 0
      die()
    else
      @squads = total_hp / @max_hp
      modulus = total_hp % @max_hp
      if modulus > 0
        @squads += 1
        @hp = modulus
      else
        @hp = @max_hp
      end
    end
    dmg
  end

  def dmg
    @squads * (@dmg + Random.rand(@dmg * 0.2)).round(0)
  end

  class << self
    def has_any? user
      @@units.select{|id, unit| unit.user_id == user.id && unit.type == :company}.length > 0
    end
  end

end

class BotCompany < Company
  def initialize(user)
    super(user)
    @hp = 300
    @dmg = 20
  end
end

class GreenOrb < Unit
  MAX_ORBS = 3

  def initialize()
    super(:orb)
    @hp = 100
    @dmg = 20
  end

  class << self
    def length
      @@units.select{|k,unit| unit.type == :orb}.length
    end

    def below_limit?
      self.length < MAX_ORBS
    end
  end
end

class Town < Unit
  attr_accessor :adj_companies
  attr_reader :buildings, :actions

  def initialize(user)
    super(:town, user)
    @hp = @max_hp = 300
    @dmg = 5
    @buildings = {
      #:tavern => Tavern.new,
      :barracs => Barracs.new,
      :banner_shop => BannerShop.new
    }
    @actions = []
    @adj_companies = []
  end

  def place(x = nil, y = nil)
    if @x.nil? && @y.nil?
      super(x, y)
    end
  end

  def build building_id
    if @buildings[building_id].build
      update_actions
      return true
    end
    false
  end

  # select actions available based on constructed buildings for town menu
  def update_actions
    @actions = @buildings.values.map{|b| b.actions}.flatten
  end

  class << self
    def has_any? user
      @@units.select{|id, unit| unit.user_id == user.id && unit.type == :town}.length > 0
    end
  end
end
