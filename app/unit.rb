class Unit
  attr_reader :id, :type, :user_id, :score
  attr_accessor :x, :y, :hp

  @@id = 1

  # @user login string
  def initialize(type, user_id = nil)
    @id = @@id
    @@id += 1
    @type = type
    @user_id = user_id
    @dead = false
    @x = nil
    @y = nil
  end
  
  def dead?
    @dead
  end

  def alive?
    !dead?
  end

  def take_dmg(dmg)
    @hp -= dmg
    if @hp <= 0
      @dead = true
    end
    dmg
  end

  def die
    @dead = true
  end

  def dmg
    @dmg + Random.rand(@dmg)
  end

  def to_json(generator=JSON.generator)
    hash = {}
    self.instance_variables.each do |var|
      hash[var] = self.instance_variable_get var
    end
    # why separate?
    hash[:type] = @type
    hash.to_json
  end

  def place(x = nil, y = nil)
    @x = x
    @y = y
  end
end

class Hero < Unit
  def initialize(user_id)
    super('PlayerHero', user_id)
    @hp = 150
    @dmg = 30
  end
end

class BotHero < Hero
  def initialize(user_id)
    super(user_id)
    @hp = 300
    @dmg = 20
  end
end

class GreenOrb < Unit
  def initialize
    super('GreenOrb')
    @hp = 100
    @dmg = 20
  end
end

class Town < Unit
  def initialize(user_id)
    super('Town', user_id)
  end
end
