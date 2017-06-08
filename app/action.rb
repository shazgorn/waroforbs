class Action < JSONable
  @label = 'Default action'
  @name = :default_action
  @on = false

  attr_reader :name, :on

  def initialize(on)
    @on = on
  end

  def on
    @on = true
  end

  def on?
    @on == true
  end

  def off
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

class NewHeroAction < Action
  NAME = :new_hero_action
  def initialize(on)
    super(on)
    @name = NAME
    @label = 'New hero'
  end
end
