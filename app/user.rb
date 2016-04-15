class User
  attr_reader :login, :id
  attr_accessor :active_unit_id

  @@id = 1
  
  def initialize(login)
    @id = @@id
    @@id += 1
    @login = login
    @active_unit_id = nil
    @actions = []
  end

  def actions
    @actions
  end
end

class AdminUser < User
  @actions = [:spawn_bot]
end

class Bot < User
  def initialize(login)
    super(login)
    @hero = BotHero.new(@login)
  end
end
