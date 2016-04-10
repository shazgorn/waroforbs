class Unit
  attr_reader :id, :type, :user, :hp, :x, :y

  @@id = 1

  # @user login string
  # change user_id to user
  def initialize(type, user = nil)
    @id = @@id
    @@id += 1
    @type = type
    @user = user
    @dead = false
    @x = nil
    @y = nil
  end

  def to_hash()
    hash = {}
    self.instance_variables.each do |var|
      unless var == :@user
        hash[var] = self.instance_variable_get var
      end
    end
    if @user
      hash[:@user_name] = @user.login
      hash[:@user_id] = @user.id
    end
    hash
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
  end

  def user_id
    if @user
      @user.id
    else
      nil
    end
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

  def place(x = nil, y = nil)
    @x = x
    @y = y
  end

end

class Hero < Unit
  def initialize(user)
    super('PlayerHero', user)
    @hp = 150
    @dmg = 30
  end
end

class BotHero < Hero
  def initialize(user)
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
  def initialize(user)
    super('Town', user)
  end
end
