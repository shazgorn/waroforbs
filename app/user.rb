class User
  attr_reader :score, :login
  attr_accessor :ws, :hero, :heroes

  @@id = 1
  
  def initialize(login)
    @id = @@id
    @@id += 1
    @login = login
    @score = 0
    @ws = nil
    @heroes = []
    @hero = add_hero
  end

  def inc_score(inc)
    @score += inc
  end

  def add_hero
    hero = Hero.new(@login)
    @heroes.push(hero)
    hero
  end

end

class Bot < User
  def initialize(login)
    super(login)
    @hero = BotHero.new(@login)
  end
end
