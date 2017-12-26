require 'building'

class Sawmill < Building
  def initialize
    @type = :sawmill
    @name = I18n.t('Sawmill')
    super
  end
end
