# mirror for ws.coffee
require 'em-websocket'
require 'json'
require 'rmagick'
require 'fileutils'

require_relative 'jsonable'
require_relative 'building'
require_relative 'banner'
require_relative 'unit'
require_relative 'user'
require_relative 'map'
require_relative 'attack'
require_relative 'game'

class OrbError < RuntimeError
end

class WrongToken < OrbError
end

# Class
class OrbApp
  MAX_BOTS = 1
  
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

  def get_ws_by_user user
    @ws_pool.select{|w| w[:user] == user}.first
  end

  # run me last, infinite loop you know
  def run_ws
    EM.run do
      EM::WebSocket.run(:host => ARGV[0] || '0.0.0.0', :port => 9293) do |ws|
        ws.onopen do |hanshake|
          puts "WebSocket connection open"
          @ws_pool[ws.signature] = {:ws => ws}
        end

        ws.onclose do
          puts 'Connection closed'
          @ws_pool.delete ws.signature
        end

        ws.onmessage do |msg, type|
          begin
            puts "Recieved message: #{msg} #{type}"
            start = Time.now.to_f
            data = JSON.parse(msg)
            token = data['token']
            user = @game.get_user_by_token token
            if data.has_key?('unit_id')
              user.active_unit_id = active_unit_id = data['unit_id'].to_i
            end
            case data['op'].to_sym
            when :init
              @ws_pool[ws.signature][:user] = user = @game.init_user token
              ws.send JSON.generate({:data_type => 'init_map',
                                     :map_shift => Map::SHIFT,
                                     :cell_dim_in_px => Map::CELL_DIM_PX,
                                     :block_dim_in_cells => Map::BLOCK_DIM,
                                     :block_dim_in_px => Map::BLOCK_DIM_PX,
                                     :map_dim_in_blocks => Map::BLOCKS_IN_MAP_DIM,
                                     :active_unit_id => user.active_unit_id,
                                     :user_id => user.id,
                                     :actions => user.actions_arr,
                                     :banners => Banner.get_by_user(user),
                                     :units => @game.all_units(user),
                                     :cells => @game.map.cells,
                                     :building_states => {
                                       :BUILDING_STATE_CAN_BE_BUILT => Building::STATE_CAN_BE_BUILT,
                                       :BUILDING_STATE_IN_PROGRESS => Building::STATE_IN_PROGRESS,
                                       :BUILDING_STATE_BUILT => Building::STATE_BUILT
                                     }
                                    })
            when :close
              dispatch_units
            when :units
              dispatch_units user
            when :move
              params = data['params']
              if params['dx'].to_i && params['dy'].to_i
                res = @game.move_hero_by user, data['unit_id'], params['dx'].to_i, params['dy'].to_i
                if res[:moved]
                  log = "Unit ##{data['unit_id']} moved by #{params['dx'].to_i}, #{params['dy'].to_i} to #{res[:new_x]}, #{res[:new_y]}"
                  dispatch_units user, :move, {:active_unit_id => user.active_unit_id, :log => log}
                else
                  dispatch_units
                end
              else
                dispatch_units
              end
            when :attack
              params = data['params']
              res = @game.attack user, active_unit_id, params['id'].to_i
              ws.send JSON.generate({
                                      :data_type => 'dmg',
                                      :dmg => res[:a_data][:dmg],
                                      :ca_dmg => res[:a_data][:ca_dmg],
                                      :a_id => user.active_unit_id,
                                      :a_dead => res[:a_data][:dead],
                                      :d_id => params['id']
                                    })
              if res.has_key? :d_data && !res[:d_user].nil?
                d_ws = get_ws_by_user res[:d_user]
                d_ws.send JSON.generate(res[:d_data])
              end
              dispatch_units user, :attack, {:active_unit_id => user.active_unit_id}
            when :spawn_bot
              spawn_bot
            when :revive
              @game.revive token
              dispatch_units
            when :new_hero
              @game.new_random_hero user
              dispatch_units user, :new_hero, {:active_unit_id => user.active_unit_id}
            when :new_town
              @game.new_town user, user.active_unit_id
              dispatch_units
            when :restart
              @game.restart token
              dispatch_units
            when :build
              res = @game.build user, data['building'].to_sym
              if res
                log = "#{data['building']} building in progress"
              else
                log = "#{data['building']} not built"
              end
              dispatch_units user, :log, {:log => log}
            when :create_random_banner
              res = @game.create_random_banner user
              if res.nil?
                log = "Unable to create more banners. Limit reached."
              else
                log = "Banner created"
              end
              dispatch_units user, :log, {:log => log}
            when :delete_banner
              res = @game.delete_banner user, data['banner_id']
              if res
                log = "Banner deleted"
              else
                log = "Unable to delete banner"
              end
              dispatch_units user, :log, {:log => log}
            when :create_default_company
              res = @game.create_default_company user
              if res.nil?
                log = "Unable to create more companies. Limit reached or no banner is available."
              else
                log = "Company created"
              end
              dispatch_units user, :log, {:active_unit_id => user.active_unit_id, :log => log}
            when :create_company_from_banner
              res = @game.create_company_from_banner user, data['banner_id']
              if res.nil?
                log = "Unable to create Company"
              else
                log = "Company created"
              end
              dispatch_units user, :log, {:active_unit_id => user.active_unit_id, :log => log}
            when :set_free_worker_to_xy
              log = "Set worker to #{data['x']}, #{data['y']}"
              begin
                @game.set_free_worker_to_xy(user, data['town_id'], data['x'], data['y'])
              rescue OrbError => log_str
                log = log_str
              end
              dispatch_units user, :log, {:log => log}
            when :free_worker
              log = "Set worker free on #{data['x']}, #{data['y']}"
              begin
                @game.free_worker user, data['town_id'], data['x'], data['y']
              rescue OrbError => log_str
                log = log_str
              end
              dispatch_units user, :log, {:log => log}
            when :add_squad_to_company
              res = @game.add_squad_to_company user, data['company_id']
              if res
                log = "Squad added"
              else
                log = "Unable to add squad to company. Max limit reached"
              end
              dispatch_units user, :log, {:log => log}
            end #case
          rescue Exception => e
            ex e
          end
          finish = Time.now.to_f
          diff = finish - start
          puts "%10.5f" % diff.to_f
        end
      end
    end
  end

  def run_ap_restorer
    Thread.new do
      while true
        begin
          Unit.all.values.each{|unit|
            unit.tick
          }
        rescue => e
          ex e
        end
        sleep(3)
      end
    end
  end

  def run_green_orbs_spawner
    Thread.new do
      while true
        begin
          if GreenOrb.below_limit?
            puts "spawn green orb"
            orb = GreenOrb.new
            @game.place_at_random orb
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
    if User.all.values.count{|user| user.login.index('bot') != nil} < MAX_BOTS
      Thread.new {
        begin
          bot_name = 'bot_' + @bot_id.to_s
          @bot_id += 1
          bot = Bot.new(bot_name)
          @game.map.place_at_random bot.hero
          dmg = nil
          while true
            dmg = nil
            xy = @game.map.h2c (User.get bot.id).hero.pos
            (-1..1).each do |adx|
              (-1..1).each do |ady|
                x = xy[:x] + adx
                y = xy[:y] + ady
                res = @game.attack User.get(bot.id).hero, x, y
                dmg = res[:dmg] unless res[:dmg].nil?
              end
            end
            sleep(2)
            if dmg.nil?
              dx = Random.rand(3) - 1
              dy = Random.rand(3) - 1
              @game.move_hero_by User.get(bot.id).hero, dx, dy
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

  def dispatch_units(user = nil, action = nil, data = {})
    dispatch_changes({:data_type => 'units', :units => @game.all_units(user)}, user, action, data)
  end

  def dispatch_changes(changes, user = nil, action = nil, data = {})
    @ws_pool.each do |w|
      unless w.nil? # add w.has_key?[:user] and w[:user].nil? / Looks like there are some race conditions
        changes[:actions] = w[:user].actions_arr
        changes[:banners] = Banner.get_by_user(w[:user])
        if user && action && w[:user] == user
          w[:ws].send JSON.generate(changes.merge({:action => action}).merge(data))
        else
          w[:ws].send JSON.generate(changes)
        end
      end
    end
  end

end

app = OrbApp.new
app.run_green_orbs_spawner
app.run_ap_restorer
app.run_ws
