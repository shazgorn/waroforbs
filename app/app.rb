require 'celluloid/current'
require 'reel'

require 'pp'
require 'json'
require 'mini_magick'
require 'fileutils'
require 'logger'

require_relative 'exception'
require_relative 'config'
require_relative 'jsonable'
require_relative 'building'
require 'unit'
require_relative 'town'
require_relative 'user'
require_relative 'map'
require_relative 'attack'
require_relative 'client_container'
require_relative 'socket_reader'
require_relative 'socket_writer'
require_relative 'facade'
require_relative 'orb_tick'
require_relative 'orb_websockets_server'
require_relative 'game'

JSON.dump_default_options[:max_nesting] = 10
Game.supervise({as: :game})

OrbTick.new

OrbWebsocketsServer.run

puts 'sleep'
sleep
