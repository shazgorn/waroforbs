##
# Loot box

class Chest < Unit
  include Expirable

  TYPE = :chest

  def initialize(x, y)
    super(TYPE, x, y)
    Config['resource'].keys.each{|res|
      @inventory[res.to_sym] = rand(1..Config[:max_random_res][res])
    }
    @name = I18n.t(TYPE)
  end

  class << self
    def all
      @@units.select{|id, unit| unit.type == TYPE}
    end
  end
end
