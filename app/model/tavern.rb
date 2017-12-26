require 'building'

class Tavern < Building
  def initialize
    @type = :tavern
    @name = I18n.t('Tavern')
    super
  end

  def actions
    if built? # TODO: and barracs.built?
      [HireHeroSwordsmanAction.new(true)]
    else
      [HireHeroSwordsmanAction.new(false)]
    end
  end
end
