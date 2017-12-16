require 'building'

class Barracs < Building
  def initialize
    @name = 'barracs'
    @title = I18n.t('Barracs')
    super
  end

  def actions
    if built?
      [HireSwordsmanAction.new(true)]
    else
      [HireSwordsmanAction.new(false)]
    end
  end
end
