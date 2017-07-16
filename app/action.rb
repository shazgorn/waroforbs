require 'jsonable'

class Action < JSONable
  @label = 'Default action'
  @name = :default_action
  @on = false

  attr_reader :name, :on

  def initialize(on)
    @on = on
  end

  def on!
    @on = true
  end

  def on?
    @on == true
  end

  def off!
    @on = false
  end

  def off?
    @on == false
  end
end

class NewTownAction < Action
  NAME = :new_town_action
  def initialize(on)
    super(on)
    @name = NAME
    @label = 'New town'
  end
end

class NewRandomInfantryAction < Action
  NAME = :new_random_infantry_action
  def initialize(on)
    super(on)
    @name = NAME
    @label = 'New random infantry'
  end
end
