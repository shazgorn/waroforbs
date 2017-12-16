require 'building'

class Roads < Building
  def initialize
    @name = 'roads'
    @title = I18n.t('Roads')
    super
  end
end
