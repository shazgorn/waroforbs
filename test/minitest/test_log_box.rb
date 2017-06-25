require "minitest/autorun"
require "pp"

require "./app/log_box"

class TestLogBox < MiniTest::Test
  def setup

  end

  def test_error
    log_entry = LogEntry.error 'test_error'
    assert log_entry.type, :error
  end

  def test_push
    log_entry = LogEntry.error 'test_error'
    LogBox << log_entry
  end

end
