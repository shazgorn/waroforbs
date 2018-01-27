##
# Resource on map

class Resource < Unit
  include Expirable
  include PublicStorage
  include Passable

  def initialize(x, y)
    resources = Config[:resource].keys
    type = resources[rand(resources.length)]
    super(type, x, y)
    @inventory[type] = rand(1..Config[:max_random_res][type])
    @name = I18n.t(type.to_s)
  end

  class << self
    def all
      @@units.select{|id, unit| Config[:resource].keys.include? unit.type}
    end
  end
end
