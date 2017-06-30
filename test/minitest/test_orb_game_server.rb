require 'celluloid/current'
require "minitest/autorun"

require "./app/logging"
require "./app/config"
require "./app/game"
require "./app/orb_game_server"

class TestOrbGameServer < MiniTest::Test
  def test_unit
    #Celluloid.shutdown
    #Celluloid.boot
    server = OrbGameServer.new
    user_data = server.parse_data 'test'
    p user_data

  end
end
