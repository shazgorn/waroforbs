require 'building'

class Factory < Building
  def initialize
    @type = :factory
    @name = I18n.t('Factory')
    super
  end
end
