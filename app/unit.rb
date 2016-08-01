class Unit
  attr_reader :id, :type, :user, :hp, :x, :y
  attr_accessor :ap

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
    @max_ap = 0
    @ap = @max_ap
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

  # restore some amount of @ap per tick
  def restore_ap
    if @ap <= @max_ap - 1
      @ap += 1
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
    
    def green_orbs_length
      @@units.select{|k,unit| unit.type == :orb}.length
    end

    def select_active_unit user
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :hero}.first
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
      @@units.values.select{|unit| unit.user_id == user.id && unit.type == :hero}.length > 0
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

class Hero < Unit
  def initialize(user, banner)
    super(:hero, user)
    @banner = banner
    @banner.unit = self
    @dmg = 30 * banner.mod_attack
    @hp = @max_hp = 50 * banner.mod_max_hp
    @ap = @max_ap = 100 * banner.mod_max_ap
  end

  def die
    super
    @banner.unit = nil
  end
end

class BotHero < Hero
  def initialize(user)
    super(user)
    @hp = 300
    @dmg = 20
  end
end

class GreenOrb < Unit
  def initialize()
    super(:orb)
    @hp = 100
    @dmg = 20
  end
end

class Town < Unit
  attr_reader :buildings, :actions

  def initialize(user)
    super(:town, user)
    @hp = 1000
    @dmg = 5
    @buildings = {
      #:tavern => Tavern.new,
      :barracs => Barracs.new,
      :banner_shop => BannerShop.new
    }
    @actions = []
  end

  def place(x = nil, y = nil)
    if @x.nil? && @y.nil?
      super(x, y)
    end
  end

  def build building_id
    @buildings[building_id].build
    update_actions
  end

  # select actions available based on constructed buildings for town menu
  def update_actions
    @actions = @buildings.values.map{|b| b.actions}.flatten
  end

  class << self
    
  end
end
