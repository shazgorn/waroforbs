class User
  attr_reader :login, :id
  attr_accessor :ws, :active_unit_id

  @@id = 1
  
  def initialize(login)
    @id = @@id
    @@id += 1
    @login = login
    @ws = nil
    @active_unit_id = nil
  end
end

class Bot < User
  def initialize(login)
    super(login)
    @hero = BotHero.new(@login)
  end
end
