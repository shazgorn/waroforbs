require 'celluloid/current'
require 'reel'
require 'i18n'
require 'pp'
require 'json'
require 'mini_magick'
require 'fileutils'

require 'exception'
require 'config'
require 'jsonable'
require 'building'
require 'unit'
require 'town'
require 'user'
require 'map'
require 'attack'
require 'client_container'
require 'socket_reader'
require 'socket_writer'
require 'facade'
require 'orb_tick'
require 'orb_websockets_server'
require 'game'

begin
  JSON.dump_default_options[:max_nesting] = 10
  game_supervisor = Game.supervise({as: :game})

  I18n.load_path = Dir[File.join('app/locales', '*.yml')]
  I18n.default_locale = :ru

  OrbTick.new

  OrbWebsocketsServer.run
  puts 'Going to sleep'
  sleep
rescue Interrupt => e
  puts "Shutting down by #{e.inspect}"
  game_supervisor.terminate
  exit
end
