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
require_relative 'banner'
require_relative 'unit'
require_relative 'town'
require_relative 'user'
require_relative 'map'
require_relative 'attack'
require_relative 'orb_client_reader'
require_relative 'orb_client_writer'
require_relative 'request_layer'
require_relative 'orb_tick'
require_relative 'orb_websockets_server'
require_relative 'game'

JSON.dump_default_options[:max_nesting] = 10
Game.supervise as: :game

OrbTick.new

OrbWebsocketsServer.run

puts 'sleep'
sleep
