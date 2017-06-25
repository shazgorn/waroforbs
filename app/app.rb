require 'celluloid/current'
require 'reel'

require 'pp'
require 'json'
require 'mini_magick'
require 'fileutils'
require 'yaml'
require 'logger'

require_relative 'cli'
require_relative 'exception'
require_relative 'logging'
require_relative 'log'
require_relative 'config'
require_relative 'jsonable'
require_relative 'building'
require_relative 'banner'
require_relative 'unit'
require_relative 'town'
require_relative 'orb'
require_relative 'action'
require_relative 'user'
require_relative 'map'
require_relative 'attack'
require_relative 'game'
require_relative 'orb_game_server'
require_relative 'orb_client_reader'
require_relative 'orb_client_writer'
require_relative 'orb_read_notifier'
require_relative 'orb_tick'
require_relative 'orb_websockets_server'

puts 'start OrbGameServer'
OrbGameServer.new
puts 'start Tick'
OrbTick.new
puts 'start OrbReadNotifier'
OrbReadNotifier.new
puts 'start OrbWebsocketsServer'
OrbWebsocketsServer.run

puts 'sleep'
sleep
