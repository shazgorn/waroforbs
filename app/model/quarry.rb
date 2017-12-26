require 'building'

class Quarry < Building
  def initialize
    @type = :quarry
    @name = I18n.t('Quarry')
    super
  end
end
