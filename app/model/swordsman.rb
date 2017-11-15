require 'unit'

class Swordsman < Unit
  MAX_SQUADS = 10
  BASE_DMG = 30
  BASE_AP = 20
  BASE_DEF = 10

  def initialize(x, y, user)
    super(:squad, x, y, user)
    @damage = BASE_DMG
    @defence = BASE_DEF
    @ap = @max_ap = BASE_AP
    @name = I18n.t(self.class.name)
  end

  def die
    super
  end

  def dmg
    @squads * (@damage + Random.rand(@damage * 0.2)).round(0)
  end

  class << self
    def has_any? user
      @@units.select{|id, unit| unit.user_id == user.id && unit.type == :squad}.length > 0
    end

    def has_any_live? user
      @@units.select{|id, unit| unit.user_id == user.id && unit.alive? && unit.type == :squad}.length > 0
    end

    def count user
      @@units.select{|id, unit| unit.user_id == user.id && unit.alive? && unit.type == :squad}.length
    end
  end

end

