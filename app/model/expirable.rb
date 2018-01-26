module Expirable
  def expired?
    Time.now - @created_time  > Config[:resource_lifetime_in_the_wild]
  end

  ##
  # Destroy if empty

  def take_res(res, q)
    q = super(res, q)
    @inventory.each{|ires, iq|
      return q if iq > 0
    }
    disappear
    # not great
    Unit.delete(@id)
    return q
  end
end
