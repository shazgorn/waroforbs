require "minitest/autorun"

require './app/jsonable'
require "./app/map"
require './app/action'
require './app/user'
require "./app/game"

class TestGame < MiniTest::Test
  def setup
    @game = Game.new
  end

  def test_init_user
    user = @game.init_user 'test_user'
    refute_nil user
  end
end
