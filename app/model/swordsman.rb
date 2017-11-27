require 'unit'

class Swordsman < Unit
  def initialize(x, y, user)
    super(:swordsman, x, y, user)
    @name = I18n.t(self.class.name)
  end

  def die
    super
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
