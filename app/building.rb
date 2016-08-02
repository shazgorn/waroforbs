# status = 0 can be built
# status = 1 in progress
# status = 2 already build
class Building
  STATE_CAN_BE_BUILT = 0
  STATE_IN_PROGRESS = 1
  STATE_BUILT = 2

  def initialize
    @status = STATE_CAN_BE_BUILT
  end

  def build
    @status = STATE_BUILT
    true
  end

  def built?
    @status == STATE_BUILT
  end

  def actions
    []
  end

  def to_hash()
    hash = {}
    self.instance_variables.each do |var|
      hash[var] = self.instance_variable_get var
    end
    hash
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
  end
end

class Tavern < Building
  def initialize
    super
    @name = 'Tavern'
  end
end

class Barracs < Building
  def initialize
    super
    @name = 'Barracs'
  end

  def actions
    if built?
      [:create_default_company]
    else
      []
    end
  end
end

class BannerShop < Building
  def initialize
    super
    @name = 'Banner Shop'
  end
end
