require 'building'

class Farm < Building
  def initialize
    @type = :farm
    @name = I18n.t('Farm')
    super
  end
end
