require 'em-websocket'
require 'json'
require 'rmagick'
require 'fileutils'

require_relative 'unit'
require_relative 'user'
require_relative 'map'
require_relative 'game'

class OrbError < RuntimeError
end

class WrongToken < OrbError
end

# Class
class OrbApp
  MAX_ORBS = 10
  MAX_BOTS = 5
  
  def initialize
    @ws_pool = []
    @game = Game.new
    @bot_id = 1
    JSON.dump_default_options[:max_nesting] = 10
  end

  def ex(e)
    puts "#{e.class} #{e.message}"
    puts e.backtrace.join("\n")
  end

  # run me last, infinite loop you know
  def run_ws
    EM.run do
      EM::WebSocket.run(:host => ARGV[0] || '0.0.0.0', :port => 9293) do |ws|
        ws.onopen do |hanshake|
          puts 'WebSocket connection open'
          @ws_pool[ws.signature] = ws
        end

        ws.onclose do
          puts 'Connection closed'
          @ws_pool[ws.signature] = nil
        end

        ws.onmessage do |msg|
          begin
            puts "Recieved message: #{msg}"
            obj = JSON.parse(msg)
            token = obj['token']
            case obj['op'].to_sym
            when :init
              if @game.users.key? token
                user = @game.users[token]
              else
                @game.users[token] = user = User.new(token)
                user.ws = ws
              end
              @game.map.place_at_random user.hero
              ws.send JSON.generate({:data_type => 'init_map',
                                     :map_shift => Map::SHIFT,
                                     :cell_dim_in_px => Map::CELL_DIM,
                                     :block_dim_in_cells => Map::BLOCK_DIM,
                                     :block_dim_in_px => Map::BLOCK_DIM_PX,
                                     :map_dim_in_blocks => Map::BLOCKS_IN_MAP_DIM,
                                     :ul => @game.map.ul})
            when :close
              @game.map.remove @game.users[token].hero
              @game.users.delete token
              dispatch_units
            when :ul
              ws.send JSON.generate({:data_type => 'ul', :ul => @game.map.ul})
            when :move
              params = obj['params']
              @game.map.move_by @game.users[token].hero, params['dx'], params['dy']
              dispatch_units
            when :attack
              params = obj['params']
              damages = @game.attack @game.users[token].hero, params['x'], params['y']
              ws.send JSON.generate({
                                      :data_type => 'dmg',
                                      :x => params['x'],
                                      :y => params['y'],
                                      :dmg => damages[:a_data][:dmg],
                                      :ca_dmg => damages[:a_data][:ca_dmg]
                                    })
              if damages.has_key? :d_data && !damages[:d].nil?
                @game.users[damages[:d].user].ws.send JSON.generate(damages[:d_data])
              end
              dispatch_units
              dispatch_scores
            when :spawn_bot
              spawn_bot
            when :revive
              @game.revive @game.users[token].hero
              ws.send JSON.generate({
                                      :data_type => 'dmg',
                                      :x => params['x'],
                                      :y => params['y']
                                    })
              dispatch_units
            end #case
          rescue Exception => e
            ex e
          end
        end
      end
    end
  end

  def run_green_orbs_spawner
    Thread.new do
      while true
        begin
          count = @game.map.ul.count{|unit| unless unit[1].nil? then unit[1].type == 'GreenOrb' end}
          if count < MAX_ORBS
            orb = GreenOrb.new
            @game.map.place_at_random orb
            dispatch_units
          end
        rescue => e
          ex e
        end
        sleep(1)
      end
    end
  end

  def spawn_bot
    if @game.users.values.count{|user| user.login.index('bot') != nil} < MAX_BOTS
      Thread.new {
        begin
          bot_name = 'bot_' + @bot_id.to_s
          @bot_id += 1
          @game.users[bot_name] = bot = Bot.new(bot_name)
          @game.map.place_at_random bot.hero
          dmg = nil
          while true
            dmg = nil
            xy = @game.map.h2c @game.users[bot_name].hero.pos
            (-1..1).each do |adx|
              (-1..1).each do |ady|
                x = xy[:x] + adx
                y = xy[:y] + ady
                res = @game.attack @game.users[bot_name].hero, x, y
                dmg = res[:dmg] unless res[:dmg].nil?
              end
            end
            dispatch_scores
            sleep(2)
            if dmg.nil?
              dx = Random.rand(3) - 1
              dy = Random.rand(3) - 1
              @game.map.move_by @game.users[bot_name].hero, dx, dy
            end
            dispatch_units
            sleep(1)
          end
        rescue => e
          puts "#{e.message}"
        end
      }
    end
  end

  def dispatch_scores
    dispatch_changes({:data_type => 'scores', :scores => @game.collect_scores})
  end

  def dispatch_units
    dispatch_changes({:data_type => 'ul', :ul => @game.map.ul})
  end

  def dispatch_changes(changes)
    @ws_pool.each do |ws|
      unless ws.nil?
        ws.send JSON.generate(changes)
      end
    end
  end
end

app = OrbApp.new
app.run_green_orbs_spawner
app.run_ws
