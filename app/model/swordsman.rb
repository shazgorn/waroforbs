require 'unit'

class Swordsman < Unit
  TYPE = :swordsman
  def initialize(x, y, user)
    super(TYPE, x, y, user)
    @name = I18n.t('Swordsman')
  end
end
