# mirror for ws.coffee
require 'em-websocket'
require 'json'
require 'rmagick'
require 'fileutils'
require 'yaml'
require 'logger'

require_relative 'logging'
require_relative 'log'
require_relative 'config'
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
  include Logging

  def initialize
    generate = false
    ARGV.each{|k|
      case k
      when 'gen'
        generate = true
      when 'stop'
        stop
        exit
      end
    }
    File.open(Config.get('pid'), 'w') {|f|
      f.write Process.pid
    }

    logger.info "Create app"
    # conn_pool => {ws.signature => {:ws => ws, :user => user}}
    @conn_pool = {}
    @game = Game.new(generate)
    JSON.dump_default_options[:max_nesting] = 10
  end

  def stop
    if File.exist?(Config.get('pid'))
      pid = nil
      File.open(Config.get('pid')) {|file|
        pid = file.readline.to_i
      }
      begin
        if pid
          Process.kill("HUP", pid)
        end
      rescue Errno::ESRCH => e
        Logging.logger.info "%s with pid %d" % [e.message, pid]
      end
    end
  end

  def ex(e)
    logger.error "#{e.class} #{e.message}"
    logger.error e.backtrace.join("\n")
  end

  def get_conn_by_user user
    @conn_pool.values.select{|conn| conn && conn.has_key?(:user) && conn[:user] == user}.first
  end

  def user_online? user
    !get_conn_by_user(user).nil?
  end

  def send_attack_info_to_def res
    if !res return false end
    if !res.has_key?(:d_user) return false end
    if !res[:d_user] return false end

    d_conn = get_conn_by_user res[:d_user]
    if d_conn d_conn[:ws].send JSON.generate(res[:d_data]) end
    true
  end

  # run me last, infinite loop you know
  def run_ws
    begin
      logger.info 'Start ws'
      EM.run do
        EM::WebSocket.run(:host => Config.get("host"), :port => Config.get("port")) do |ws|
          ws.onopen do |handshake|
            logger.info "WebSocket connection open"
            @conn_pool[ws.signature] = {:ws => ws}
          end

          ws.onclose do
            logger.info 'Connection closed'
            @conn_pool.delete ws.signature
          end

          ws.onerror { |error|
            ex e
          }

          ws.onmessage do |msg, type|
            begin
              logger.info "Recieved message: #{msg} #{type}"
              start = Time.now.to_f
              data = JSON.parse(msg)
              token = data['token']
              user = @game.get_user_by_token token
              if data.has_key?('unit_id')
                user.active_unit_id = active_unit_id = data['unit_id'].to_i
              end
              case data['op'].to_sym
              when :init
                user = @game.init_user token
                old_conn = get_conn_by_user user
                if old_conn
                  @conn_pool.delete old_conn[:ws].signature
                end
                @conn_pool[ws.signature][:user] = user
                dispatch_units({user.id => {:data_type => 'init_map'}.merge(@game.init_map user)})
              when :close
                dispatch_units
              when :units
                dispatch_units
              when :move
                params = data['params']
                if params['dx'].to_i && params['dy'].to_i
                  begin
                    res = @game.move_user_hero_by user, data['unit_id'], params['dx'].to_i, params['dy'].to_i
                    log = "Unit ##{data['unit_id']} moved by #{params['dx'].to_i}, #{params['dy'].to_i} to #{res[:new_x]}, #{res[:new_y]}"
                    Log.log user, log
                    dispatch_units({user.id => {:active_unit_id => user.active_unit_id, :log => log}})
                  rescue OrbError => log_str
                    log = log_str
                    Log.log user, log
                    dispatch_units({user.id => {:log => log}})
                  end
                else
                  dispatch_units
                end
              when :attack
                params = data['params']
                begin
                  log = nil
                  users = {}
                  res = @game.attack_by_user user, active_unit_id, params['id'].to_i
                  users[user.id] = {
                    :active_unit_id => user.active_unit_id,
                    :dmg => res[:a_data][:dmg],
                    :ca_dmg => res[:a_data][:ca_dmg],
                    :a_id => user.active_unit_id,
                    :dead => res[:a_data][:dead],
                    :d_id => params['id']
                  }
                  if res.has_key?(:d_user) && res[:d_user] && user_online?(res[:d_user])
                    users[res[:d_user].id] = res[:d_data]
                  end
                  Log.log user, "attack"
                  dispatch_units(users)
                rescue OrbError => log_str
                  log = log_str
                  Log.log user, log
                  dispatch_units({user.id => {:active_unit_id => user.active_unit_id, :log => log}})
                end
              when :new_hero
                @game.new_random_hero user
                log = 'New hero spawned'
                Log.log user, log
                dispatch_units({user.id => {:active_unit_id => user.active_unit_id, :log => log}})
              when :new_town
                begin
                  @game.new_town user, user.active_unit_id
                  log = 'Town has been settled'
                rescue OrbError => log_str
                  log = log_str
                end
                Log.log user, log
                dispatch_units({user.id => {:log => log}})
              when :disband
                unit_id = data['unit_id']
                begin
                  @game.disband user, unit_id
                  log = "Unit ##{unit_id} disbanded"
                rescue OrbError => log_str
                  log = log_str
                end
                Log.log user, log
                dispatch_units({user.id => {:log => log}})
              when :restart
                @game.restart token
                dispatch_units
              when :build
                begin
                  res = @game.build user, data['building'].to_sym
                  if res
                    log = "#{data['building']} building in progress"
                  else
                    log = "#{data['building']} not built"
                  end
                rescue OrbError => log_str
                  log = log_str
                end
                Log.log user, log
                dispatch_units({user.id => {:log => log}})
              when :create_random_banner
                log = "Banner bought"
                begin
                  res = @game.create_random_banner user
                rescue OrbError => log_str
                  log = log_str
                end
                Log.log user, log
                dispatch_units({user.id => {:log => log}})
              when :delete_banner
                res = @game.delete_banner user, data['banner_id']
                if res
                  log = "Banner deleted"
                else
                  log = "Unable to delete banner"
                end
                Log.log user, log
                dispatch_units({user.id => {:log => log}})
              when :create_default_company
                res = @game.create_company user, :new
                if res.nil?
                  log = "Unable to create more companies. Limit reached or no banner is available."
                else
                  log = "Company created"
                end
                Log.log user, log
                dispatch_units({user.id => {:active_unit_id => user.active_unit_id, :log => log}})
              when :create_company_from_banner
                res = @game.create_company user, data['banner_id']
                if res.nil?
                  log = "Unable to create Company"
                else
                  log = "Company created"
                end
                Log.log user, log
                dispatch_units({user.id => {:active_unit_id => user.active_unit_id, :log => log}})
              when :set_free_worker_to_xy
                log = "Set worker to #{data['x']}, #{data['y']}"
                begin
                  @game.set_free_worker_to_xy(user, data['town_id'], data['x'], data['y'])
                rescue OrbError => log_str
                  log = log_str
                end
                Log.log user, log
                dispatch_units({user.id => {:log => log}})
              when :free_worker
                log = "Set worker free on #{data['x']}, #{data['y']}"
                begin
                  @game.free_worker user, data['town_id'], data['x'], data['y']
                rescue OrbError => log_str
                  log = log_str
                end
                Log.log user, log
                dispatch_units({user.id => {:log => log}})
              when :add_squad_to_company
                log = "Squad added"
                begin
                  res = @game.add_squad_to_company user, data['town_id'], data['company_id']
                rescue OrbError => log_str
                  log = log_str
                end
                Log.log user, log
                dispatch_units({user.id => {:log => log}})
              end #case
            rescue Exception => e
              ex e
            end
            finish = Time.now.to_f
            diff = finish - start
            logger.info "%10.5f" % diff.to_f
          end
        end
      end # run
    rescue Interrupt
      save_and_exit
    end #begin
  end # run_ws

  def save_and_exit
    logger.info "Terminating..."
    @game.dump
    logger.info "Good bye!"
    exit
  end

  def run_ap_restorer
    Thread.new do
      while true
        begin
          @game.tick
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
            orb = GreenOrb.new
            @game.place_at_random orb
            logger.info "spawn green orb (%d)" % GreenOrb.length
            dispatch_units
          end
        rescue => e
          ex e
        end
        sleep(1)
      end
    end
  end

  def run_black_orb_spawner
    begin
      if @game.black_orbs_below_limit
        orb = @game.spawn_black_orb
        @game.place_at_random orb
        logger.info "spawn black orb"
        dispatch_units
        Thread.new {
          begin
            while true
              res = @game.attack_adj_cells orb
              attacked = send_attack_info_to_def res
              if attacked
                logger.info 'black orb attack'
                dispatch_units
              else
                @game.random_move orb
                dispatch_units
              end
              sleep(3)
            end
          rescue => e
            ex e
          end
        }
      end
    rescue => e
      ex e
    end
  end

  # users_data = {user.id => data, ...}
  def dispatch_units(users_data = {})
    dispatch_changes({:data_type => 'units', :units => @game.all_units(users_data)}, users_data)
  end

  # users_data = {user.id => data, ...}
  def dispatch_changes(changes, users_data = {})
    @conn_pool.each_value do |conn|
      unless conn.nil? && conn.has_key?[:user] && conn[:user]
        changes[:actions] = conn[:user].actions_arr
        changes[:banners] = Banner.get_by_user(conn[:user])
        if users_data.has_key?(conn[:user].id)
          conn[:ws].send JSON.generate(changes.merge(users_data[conn[:user].id]))
        else
          conn[:ws].send JSON.generate(changes)
        end
      end
    end
  end

end

app = OrbApp.new
app.run_green_orbs_spawner
app.run_black_orb_spawner
app.run_ap_restorer
app.run_ws
