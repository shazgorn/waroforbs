require_relative 'exception'

##
# Process request object and pass it to the game actor

class RequestLayer
  include Celluloid
  include Celluloid::Internals::Logger
  include Celluloid::Notifications
  
  def initialize
    @game = Celluloid::Actor[:game]
  end
  
  def parse_user_data(data)
    user_data = parse_data data
    if user_data
      publish "send_units_to_user", {:game => @game, :user_data => user_data}
    end
  end

  ##
  # +data+ - hash, user request, with token, op, and some params
  # return user_data with log message, op that caused message
  # dispatch and active unit id
  # use writer id or name as key in user_data, but not token

  def parse_data data
    user_data_key = data['writer_name']
    unless user_data_key
      error 'No writer name provided'
      return nil
    end
    # keep token, not user, pass token and params to game as message
    user_data = {
      user_data_key => {
      }
    }
    token = data['token']
    unless token
      err_msg = 'No token'
      error err_msg
      user_data[user_data_key][:error] = err_msg
      return user_data
    end
    op =  data['op']
    unless op
      err_msg = 'No op'
      warn err_msg
      user_data[user_data_key][:error] = err_msg
      return user_data
    end
    op = op.to_sym
    user_data[user_data_key][:op] = op
    user_data[user_data_key][:data_type] = 'units'
    log_entry = nil
    user = @game.get_user_by_token token
    if user && data.has_key?('unit_id')
      # remove duplicates of :active_unit_id setting in user_data?
      user_data[user_data_key][:active_unit_id] = user.active_unit_id = data['unit_id'].to_i
    end
    case op
    when :init_map
      user_data[user_data_key][:data_type] = :init_map
      @game.init_user token
    when :close

    when :units

    when :move
      params = data['params']
      log_entry = @game.move_user_hero_by user, data['unit_id'], params['dx'].to_i, params['dy'].to_i
    when :attack
      params = data['params']
      begin
        log = nil
        users = {}
        res = @game.attack_by_user user, user.active_unit_id, params['id'].to_i
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
    when :spawn_orb
      log_entry = @game.spawn_orb data['color'].to_sym
    else
      log_entry = LogBox.error 'Unknown op', user
    end #case
    if log_entry
      if log_entry.user
        log_entry.user = user
        LogBox << log_entry
      end
      user_data[user_data_key][:log] = log_entry
    end
    user_data
  end
end
