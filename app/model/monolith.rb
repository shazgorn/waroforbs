require 'enterable'

class Monolith < Unit
  include Enterable

  def initialize(x, y, user)
    super(:monolith, x, y, user)
  end
end
