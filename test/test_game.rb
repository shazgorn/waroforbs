require "minitest/autorun"

require "../app/map"
require "../app/game"
require "../app/unit"

class TestGame < MiniTest::Test
  def setup
    @game = Game.new
  end
end
