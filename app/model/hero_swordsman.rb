require 'unit'
require 'single_entity'

class HeroSwordsman < Unit
  include SingleEntity

  def initialize(x, y, user)
    super(:hero_swordsman, x, y, user)
    @name = I18n.t('Hero swordsman')
  end
end
