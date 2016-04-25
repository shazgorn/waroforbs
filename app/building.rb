# status - 0 can be built
# status - 1 already build
class Building
  def initialize
    @status = 0
  end

  def build
    @status = 1
  end

  def built?
    @status == 1
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

  def actions
    if built?
      [:new_town_hero]
    else
      []
    end
  end
end

class Barracs < Building
  def initialize
    super
    @name = 'Barracs'
  end
end

class BannerShop < Building
  def initialize
    super
    @name = 'Banner Shop'
  end
end
