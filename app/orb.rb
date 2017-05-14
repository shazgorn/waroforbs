##
# Abstract class for black and green orbs

class Orb < Unit
  LIMIT = 1

  def initialize(type, x, y, hp, damage, defence)
    super(type, x, y)
    @max_hp = @hp = hp
    @damage = damage
    @defence = defence
  end

  class << self
    def length
      @@units.select{|k,unit| unit.type == self::TYPE}.length
    end

    ##
    # Count live orbs of some type black or green

    def live_count
      @@units.select{|k,unit| unit.type == self::TYPE && unit.alive?}.length
    end

    ##
    # Check if count of alive orbs is below its limit

    def below_limit?
      self.live_count < self::LIMIT
    end
  end
end

class GreenOrb < Orb
  LIMIT = Config.get("GREEN_ORB_PER_BLOCK") * (Config.get("BLOCKS_IN_MAP_DIM") ** 2)
  TYPE = :green_orb

  def initialize(x, y)
    super(TYPE, x, y, 100, 20, 3)
  end
end

class BlackOrb < Orb
  LIMIT = Config.get("BLACK_ORB_LIMIT")
  TYPE = :black_orb

  def initialize(x = nil, y = nil)
    super(
      TYPE,
      x,
      y,
      Config.get("BLACK_ORB_START_HP"),
      Config.get("BLACK_ORB_START_DAMAGE"),
      Config.get("BLACK_ORB_START_DEFENCE")
    )
  end

  def can_move?(cost)
    true
  end

  def lvl_up
    @damage += 1
    @defence += 1
    @max_hp += 1
  end
end
