require 'unit'

class Swordsman < Unit
  def initialize(x, y, user)
    super(:swordsman, x, y, user)
    @name = I18n.t('Swordsman')
  end
end
