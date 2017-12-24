##
# Resource on map

class Resource < Unit
  def initialize(type, x, y)
    super(type, x, y)
    @inventory[type] = rand(1..Config['max_random_res'])
    @name = I18n.t(type.to_s)
  end

  ##
  # Destroy if empty

  def take_res(res, q)
    q = super(res, q)
    @inventory.each{|ires, iq|
      return q if iq > 0
    }
    die
    # not great
    Unit.delete(@id)
    return q
  end

  def too_old?
    Time.now - @created_time  > Config['resource_lifetime_in_the_wild']
  end

  class << self
    def all
      @@units.select{|id, unit| Config['resource'].keys.include? unit.type.to_s}
    end
  end
end
