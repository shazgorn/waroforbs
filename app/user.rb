class User
  attr_reader :score, :login
  attr_accessor :hero, :ws

  @@id = 1
  
  def initialize(login)
    @id = @@id
    @@id += 1
    @login = login
    @hero = Hero.new(@login)
    @score = 0
    @ws = nil
  end

  def inc_score(inc)
    @score += inc
  end

end

class Bot < User
  def initialize(login)
    super(login)
    @hero = BotHero.new(@login)
  end
end
