require "minitest/autorun"

require "../app/user"
require "../app/building"
require "../app/unit"

class TestUnit < MiniTest::Test
  def setup
    @user = User.new('test_login')
  end

  def test_new_hero
    unit = Unit.new @user
    assert Unit.count == 1
  end
end
