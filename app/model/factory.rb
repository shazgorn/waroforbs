require 'building'

class Factory < Building
  def initialize
    @name = 'factory'
    @title = I18n.t('Factory')
    super
  end
end
