require 'building'

class Sawmill < Building
  def initialize
    @name = 'sawmill'
    @title = I18n.t('Sawmill')
    super
  end
end
