require_relative '../app/orb_game_server'

server = OrbGameServer.new
data = server.parse_data 'test'
p data
