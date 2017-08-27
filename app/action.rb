require 'jsonable'

class Action < JSONable
  attr_reader :name, :on

  def initialize(on = false)
    @on = on
    @label = I18n.t('Default action')
    @name = :default_action
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
    @label = I18n.t('New town')
  end
end

class NewRandomInfantryAction < Action
  NAME = :new_random_infantry_action
  def initialize(on)
    super(on)
    @name = NAME
    @label = I18n.t('New random infantry')
  end
end
