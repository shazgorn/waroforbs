require 'building'

class Roads < Building
  def initialize
    @type = :roads
    @name = I18n.t('Roads')
    super
  end
end
