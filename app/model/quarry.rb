require 'building'

class Quarry < Building
  def initialize
    @name = 'quarry'
    @title = I18n.t('Quarry')
    super
  end
end
