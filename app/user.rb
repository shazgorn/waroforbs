class User
  attr_reader :score, :login
  attr_accessor :ws, :hero, :heroes, :towns, :active_hero_id

  @@id = 1
  
  def initialize(login)
    @id = @@id
    @@id += 1
    @login = login
    @score = 0
    @ws = nil
    @heroes = {}
    @hero = add_hero
    @towns = {}
  end

  def inc_score(inc)
    @score += inc
  end

  def add_hero
    hero = Hero.new(@login)
    if @heroes.length == 0
      @active_hero_id = hero.id
    end
    @heroes[hero.id] = hero
    hero
  end

  def add_town
    town = Town.new(@login)
    @towns[town.id] = town
    town
  end

  def first_alive_hero
    @heroes
  end

  def active_hero
    @heroes[@active_hero_id]
  end

  def bury_hero unit_id
    @heroes.delete unit_id
    first = @heroes.values.first
    if first.nil?
      @active_hero_id = nil
    else
      @active_hero_id = first.id
    end
  end

end

class Bot < User
  def initialize(login)
    super(login)
    @hero = BotHero.new(@login)
  end
end
