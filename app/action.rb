require 'jsonable'

class Action < JSONable
  attr_reader :name, :on

  def initialize(on = false)
    @on = on
    @label = I18n.t('Default action')
    @name = :default_action
    @title = nil
    @cost = nil
    @unit_type = nil
  end

  def to_hash()
    {
      'on' => @on,
      'label' => @label,
      'name' => @name,
      'title' => @title,
      'cost' => @cost,
      'unit_type' => @unit_type
    }
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
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
  NAME = :settle_town_action

  def initialize(on)
    super(on)
    @name = NAME
    @label = I18n.t('New town')
  end
end

class HireAction < Action
  def initialize(on)
    super(on)
    @label = I18n.t('Hire')
  end
end

class HireSwordsmanAction < HireAction
  NAME = 'hire_swordsman_action'

  def initialize(on)
    super(on)
    @name = NAME
    @title = I18n.t('Swordsman')
    @unit_type = :swordsman
    @cost = Config[@unit_type][:cost_res]
  end
end

class HireHeroSwordsmanAction < HireAction
  NAME = 'hire_hero_action'

  def initialize(on)
    super(on)
    @name = NAME
    @title = I18n.t('Hero swordsman')
    @unit_type = :hero_swordsman
    @cost = Config[@unit_type][:cost_res]
  end
end
