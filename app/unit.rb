class Unit
  attr_reader :id, :type, :user, :score
  attr_accessor :pos, :x, :y, :hp

  @@id = 1

  def initialize(type, user=nil)
    @id = @@id
    @@id += 1
    @type = type
    @user = user
    @dead = false
    @score = 0
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
    hash[:type] = @type
    hash.to_json
  end

end

class Hero < Unit

  def initialize(user)
    super('PlayerHero', user)
    @hp = 10
    @dmg = 30
    @pos = 0
    @score = 10
  end

end

class BotHero < Hero
  def initialize(user)
    super(user)
    @hp = 300
    @dmg = 20
    @score = 5
  end
end

class GreenOrb < Unit

  def initialize
    super('GreenOrb')
    @hp = 100
    @dmg = 50
    @score = 3
  end

end
