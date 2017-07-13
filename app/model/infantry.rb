require 'unit'

class Infantry < Unit
  MAX_SQUADS = 10
  BASE_DMG = 30
  BASE_HP = 50
  BASE_AP = 20
  BASE_DEF = 10

  def initialize(x, y, user)
    super(:company, x, y, user)
    @damage = BASE_DMG
    @defence = BASE_DEF
    # @hp - hp of 1st squad in line
    @hp = @max_hp = BASE_HP
    @ap = @max_ap = BASE_AP
    # each company starts with one squad
    @squads = 1
  end

  def die
    super
  end

  def add_squad
    raise OrbError, 'Unable to add squad. Squads limit reached' unless @squads < MAX_SQUADS
    @squads += 1
  end

  def take_dmg(income_dmg)
    total_hp = @max_hp * (@squads - 1) + @hp
    reduced_dmg = income_dmg - (@defence * @squads)
    reduced_dmg = 1 if reduced_dmg < 1
    total_hp -= reduced_dmg
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
    reduced_dmg
  end

  def dmg
    @squads * (@damage + Random.rand(@damage * 0.2)).round(0)
  end

  class << self
    def has_any? user
      @@units.select{|id, unit| unit.user_id == user.id && unit.type == :company}.length > 0
    end

    def has_any_live? user
      @@units.select{|id, unit| unit.user_id == user.id && unit.alive? && unit.type == :company}.length > 0
    end
  end

end

