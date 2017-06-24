class OrbGameServer
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Supervision
  include Celluloid::Internals::Logger
  include Cli

  def initialize
    @generate = false
    check_args
    @game = Game.new(@generate)
    JSON.dump_default_options[:max_nesting] = 10
    subscribe('new_user_data', :parse_user_data)
    subscribe('tick', :tick)
  end

  def tick topic
    @game.tick
  end

  def parse_user_data(topic, data)
    user_data = parse_data data
    info 'data has been parsed'
    info 'publish units to users'
    publish "send_units_to_user", {:game => @game, :user_data => user_data}
  end

  ##
  # +data+ - hash, user request, with token, op, and some params
  # return user_data with log message, op that caused message
  # dispatch and active unit id

  def parse_data data
    # keep token, not user, pass token and params to game as message
    token = data['token']
    user = @game.get_user_by_token token
    # hash of {token => user_data} to be sent to users with units
    user_data = {}
    if data.has_key?('unit_id')
      user.active_unit_id = active_unit_id = data['unit_id'].to_i
    end
    op =  data['op'].to_sym
    info op
    case op
    when :init
      @game.init_user token
    when :close

    when :units
      
    when :move
      params = data['params']
      if params['dx'].to_i && params['dy'].to_i
        begin
          res = @game.move_user_hero_by user, data['unit_id'], params['dx'].to_i, params['dy'].to_i
          log_msg = "Unit ##{data['unit_id']} moved by #{params['dx'].to_i}, #{params['dy'].to_i} to #{res[:new_x]}, #{res[:new_y]}"
          log_entry = Log.push user, log_msg, op
          user_data = {
            token => {
              :active_unit_id => user.active_unit_id,
              :op => op,
              :log => log_entry
            }
          }
        rescue OrbError => log_msg
          log_entry = Log.push user, log_msg, :error
          user_data = {token => {:log => log_entry}}
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
        log_msg = "damage dealt dmg: %d, damage taken ca_dmg: %d" % [res[:a_data][:dmg], res[:a_data][:ca_dmg]]
        if res[:a_data][:dead]
          log_msg += '. Your hero has been killed.'
        end
        log_entry = Log.push user, log_msg, op
        users[user.id] = {
          :active_unit_id => user.active_unit_id,
          :dmg => res[:a_data][:dmg],
          :ca_dmg => res[:a_data][:ca_dmg],
          :a_id => user.active_unit_id,
          :dead => res[:a_data][:dead],
          :d_id => params['id'],
          :log => log_entry
        }
        set_def_data users, res
        dispatch_units(users)
      rescue OrbError => log_msg
        log_entry = Log.push user, log_msg, :error
        dispatch_units({user.id => {:active_unit_id => user.active_unit_id, :log => log_entry}})
      end
    when :new_hero
      begin
        @game.new_random_hero user
        log = 'New hero spawned'
        log_entry = Log.push user, log, op
      rescue OrbError => log_msg
        log_entry = Log.push user, log_msg, :error
      end
      dispatch_units({user.id => {:active_unit_id => user.active_unit_id, :op => op, :log => log_entry}})
    when :new_town
      begin
        @game.new_town user, user.active_unit_id
        log = 'New town has been settled'
        type = op
      rescue OrbError => log_msg
        log = log_msg
        type = :error
      end
      log_entry = Log.push user, log, type
      dispatch_units({user.id => {:log => log_entry}})
    when :dismiss
      unit_id = data['unit_id']
      begin
        @game.dismiss user, unit_id
        log = "Unit ##{unit_id} dismissed"
        type = op
      rescue OrbError => log_msg
        log = log_msg
        type = :error
      end
      log_entry = Log.push user, log, type
      dispatch_units({user.id => {:log => log_entry}})
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
        type = op
      rescue OrbError => log_msg
        log = log_msg
        type = :error
      end
      log_entry = Log.push user, log, type
      dispatch_units({user.id => {:log => log_entry}})
    when :create_random_banner
      log = "Banner bought"
      begin
        res = @game.create_random_banner user
        type = op
      rescue OrbError => log_msg
        log = log_msg
        type = :error
      end
      log_entry = Log.push user, log, type
      dispatch_units({user.id => {:log => log_entry}})
    when :delete_banner
      res = @game.delete_banner user, data['banner_id']
      if res
        log = "Banner deleted"
      else
        log = "Unable to delete banner"
      end
      log_entry = Log.push user, log, op
      dispatch_units({user.id => {:log => log_entry}})
    when :create_default_company
      res = @game.create_company user, :new
      if res.nil?
        log = "Unable to create more companies. Limit reached or no banner is available."
      else
        log = "Company created"
      end
      log_entry = Log.push user, log, op
      dispatch_units({user.id => {:active_unit_id => user.active_unit_id, :log => log_entry}})
    when :create_company_from_banner
      res = @game.create_company user, data['banner_id']
      if res.nil?
        log = "Unable to create Company"
      else
        log = "Company created"
      end
      log_entry = Log.push user, log, op
      dispatch_units({user.id => {:active_unit_id => user.active_unit_id, :log => log_entry}})
    when :set_free_worker_to_xy
      log = "Set worker to #{data['x']}, #{data['y']}"
      begin
        @game.set_free_worker_to_xy(user, data['town_id'], data['x'], data['y'])
        type = op
      rescue OrbError => log_msg
        log = log_msg
        type = :error
      end
      log_entry = Log.push user, log, type
      dispatch_units({user.id => {:log => log_entry}})
    when :free_worker
      log = "Set worker free on #{data['x']}, #{data['y']}"
      begin
        @game.free_worker user, data['town_id'], data['x'], data['y']
        type = op
      rescue OrbError => log_msg
        log = log_msg
        type = :error
      end
      log_entry = Log.push user, log, type
      dispatch_units({user.id => {:log => log_entry}})
    when :add_squad_to_company
      log = "Squad added"
      begin
        res = @game.add_squad_to_company user, data['town_id'], data['company_id']
        type = op
      rescue OrbError => log_msg
        log = log_msg
        type = :error
      end
      log_entry = Log.push user, log, type
      dispatch_units({user.id => {:log => log_entry}})
    when :spawn_green_orb
      begin
        @game.spawn_green_orb
        debug "spawn green orb (%d)" % GreenOrb.length
        log_entry = Log.push user, 'Spawn green orb', op
      rescue OrbError => log_msg
        log_entry = Log.push user, 'Unable to spawn green orb', :error
      end
      dispatch_units({user.id => {:log => log_entry}})
    when :spawn_black_orb
      begin
        @game.spawn_black_orb
        debug "spawn black orb (%d)" % BlackOrb.length
        log_entry = Log.push user, 'Spawn black orb', op
      rescue OrbError => log_msg
        log_entry = Log.push user, 'Unable to spawn black orb', :error
      end
      dispatch_units({user.id => {:log => log_entry}})
    else
      raise OrbError, 'unknown op'
    end #case
    user_data
  end

  def notify_action data
    info 'notify action'
  end
end
