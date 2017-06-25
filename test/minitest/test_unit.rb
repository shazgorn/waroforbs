require "minitest/autorun"

require "./app/user"
require "./app/building"
require "./app/unit"

class TestUnit < MiniTest::Test
  def setup
    @user = User.new('test_login')
  end

  def test_new_unit
    unit = Unit.new :test, 1, 1, @user
    assert Unit.count == 1
  end

  def test_get_by_id_nonexistent
    unit = Unit.get_by_id 12345678
    assert_nil unit
  end
end
