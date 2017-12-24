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
end
