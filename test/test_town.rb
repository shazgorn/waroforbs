require "minitest/autorun"

require "../app/user"
require "../app/building"
require "../app/unit"

class TestTown < MiniTest::Test
  def setup
    @town = Town.new User.new('test_user')
  end

  def test_build
    @town.buildings[:tavern].build
    assert @town.buildings[:tavern].built?
  end

  # test town actions
  def test_update_actions
    @town.build :tavern
    assert @town.actions.include?(:new_town_hero)
    assert @town.actions.length == 1
  end
end
