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

  def test_move
    user = @game.init_user 'test_user'
    unit = Unit.get_active_unit user
    assert unit.x > 0
    assert unit.y > 0
    log_entry = @game.move_user_hero_by user, unit.id, 1, 1
    assert_equal log_entry.type, :move
  end

  def test_attack
    user = @game.init_user 'test_user'
    orbs_user = @game.init_user 'orbs_client'
    @game.spawn_green_orb
    unit = Unit.get_active_unit user
  end
end
