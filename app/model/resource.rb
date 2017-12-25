##
# Resource on map

class Resource < Unit
  include Expirable

  def initialize(x, y)
    resources = Config['resource'].keys
    type = resources[rand(resources.length)]
    super(type.to_sym, x, y)
    @inventory[type.to_sym] = rand(1..Config['max_random_res'])
    @name = I18n.t(type.to_s)
  end

  class << self
    def all
      @@units.select{|id, unit| Config['resource'].keys.include? unit.type.to_s}
    end
  end
end
