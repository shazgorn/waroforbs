class Orb < Unit
  LIMIT = 1

  def initialize(type, hp, damage, defence)
    super(type)
    @max_hp = @hp = hp
    @damage = damage
    @defence = defence
  end

  class << self
    def length
      @@units.select{|k,unit| unit.type == self::TYPE}.length
    end

    def below_limit?
      self.length < self::LIMIT
    end
  end
end

class GreenOrb < Orb
  LIMIT = Config.get("GREEN_ORB_PER_BLOCK") * (Config.get("BLOCKS_IN_MAP_DIM") ** 2)
  TYPE = :orb

  def initialize()
    super(TYPE, 100, 20, 3)
  end
end

class BlackOrb < Orb
  LIMIT = 1
  TYPE = :black_orb

  def initialize()
    super(
      TYPE,
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
