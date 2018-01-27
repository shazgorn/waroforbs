##
# Loot box

class Chest < Unit
  include Expirable
  include PublicStorage
  include Passable

  TYPE = :chest

  def initialize(x, y)
    super(TYPE, x, y)
    @name = I18n.t(TYPE)
    random_inventory
    check_inventory
  end

  ##
  # Init chest with random resources

  def random_inventory
    Config[:resource].keys.each{|res|
      if rand(100) > 50
        @inventory[res] = rand(0..Config[:max_random_res][res])
      end
    }
  end

  ##
  # Set gold to some value if all resources are zero

  def check_inventory
    if @inventory.select{|res, q| q > 0}.length == 0
      @inventory[:gold] = rand(1..Config[:max_random_res][:gold])
    end
  end

  class << self
    def all
      @@units.select{|id, unit| unit.type == TYPE}
    end
  end
end
