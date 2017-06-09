require "minitest/autorun"

require './app/jsonable'
require './app/action'
require './app/user'

class TestUser < Minitest::Test
  def setup
    @user = User.new('test_user')
  end

  def test_actions_size
    assert_equal 2, @user.actions.size
  end

  def test_actions_values
    assert_equal false, @user.actions[NewTownAction::NAME].on?
    assert_equal false, @user.actions[NewHeroAction::NAME].on?
  end

  def test_enable_new_hero_action
    @user.enable_new_hero_action
    assert_equal true, @user.actions[NewTownAction::NAME].off?
    assert_equal true, @user.actions[NewHeroAction::NAME].on?
  end

  def test_enable_new_town_action
    @user.enable_new_town_action
    assert_equal true, @user.actions[NewTownAction::NAME].on?
    assert_equal true, @user.actions[NewHeroAction::NAME].off?
  end
end
