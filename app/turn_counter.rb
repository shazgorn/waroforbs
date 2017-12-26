class TurnCounter
  include Celluloid

  attr_reader :turns

  def initialize
    @turns = 0
  end

  def make_turn
    @turns += 1
  end
end
