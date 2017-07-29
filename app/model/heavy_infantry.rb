require 'squad'

class HeavyInfantry < Squad
  MAX_SQUADS = 10
  BASE_DMG = 30
  BASE_AP = 20
  BASE_DEF = 10

  def initialize(x, y, user)
    super(:company, x, y, user)
    @damage = BASE_DMG
    @defence = BASE_DEF
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

