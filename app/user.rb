class User
  attr_reader :score, :login, :active_hero_id
  attr_accessor :ws, :hero, :heroes

  @@id = 1
  
  def initialize(login)
    @id = @@id
    @@id += 1
    @login = login
    @score = 0
    @ws = nil
    @heroes = {}
    @hero = add_hero
    @active_hero_id = @hero.id
  end

  def inc_score(inc)
    @score += inc
  end

  def add_hero
    hero = Hero.new(@login)
    @heroes[hero.id] = hero
    hero
  end

  def first_alive_hero
    @heroes
  end

  def active_hero
    @heroes[@active_hero_id]
  end

end

class Bot < User
  def initialize(login)
    super(login)
    @hero = BotHero.new(@login)
  end
end
