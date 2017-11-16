require 'exception'

##
# Process request object and pass it to the game actor

class Facade
  include Celluloid
  include Celluloid::Internals::Logger
  include Celluloid::Notifications

  def parse_user_data(data)
    user_data = parse_data data
    if user_data
      publish "send_units_to_user", {:game => Celluloid::Actor[:game], :user_data => user_data}
    end
  end

  ##
  # +data+ - hash, user request, with token, op, and some params
  # return user_data with log message, op that caused message
  # dispatch and active unit id
  # use writer id or name as key in user_data, but not token

  def parse_data(data)
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
    user_data[user_data_key][:data_type] = :units
    user = Celluloid::Actor[:game].get_user_by_token(token)
    if user && data.has_key?('unit_id')
      # remove duplicates of :active_unit_id setting in user_data?
      user_data[user_data_key][:active_unit_id] = user.active_unit_id = data['unit_id'].to_i
    end
    make_action_on_op(op, user, data, user_data, user_data_key, token)
    if user
      user_data[user_data_key][:actions] = user.actions
      user_data[user_data_key][:user_glory] = user.glory
      user_data[user_data_key][:user_max_glory] = user.max_glory
    end
    user_data
  end

  def make_action_on_op(op, user, data, user_data, user_data_key, token)
    case op
    when :init_map
      user_data[user_data_key][:data_type] = :init_map
      Celluloid::Actor[:game].init_user(token)
    when :close

    when :units

    when :move
      params = data['params']
      Celluloid::Actor[:game].move_user_hero_by(
        user, data['unit_id'], params['dx'].to_i, params['dy'].to_i
      )
    when :attack
      params = data['params']
      res = Celluloid::Actor[:game].attack_by_user(
        user, user.active_unit_id, params['id'].to_i
      )
      if res
        user_data[user_data_key].merge!(res)
      end
    when :settle_town
      Celluloid::Actor[:game].settle_town(user, user.active_unit_id)
    when :build
      Celluloid::Actor[:game].build(user, data['building'].to_sym)
    when :spawn_orb
      Celluloid::Actor[:game].spawn_orb(data['color'].to_sym)
    when :spawn_dummy
      Celluloid::Actor[:game].spawn_dummy(data['x'], data['y'])
    when :hire_squad
      Celluloid::Actor[:game].hire_squad(user, 'swordsman')
    when :disband
      unit_id = data['unit_id']
      Celluloid::Actor[:game].disband user, unit_id
    when :restart
      Celluloid::Actor[:game].restart(user)
      user_data[user_data_key][:active_unit_id] = user.active_unit_id
    when :rename_unit
      Celluloid::Actor[:game].rename_unit(user, data['unit_id'], data['unit_name'])
    when :refill_squad
      # Not implemented!
      Celluloid::Actor[:game].refill_squad user, data['town_id'], data['unit_id']
    when :set_free_worker_to_xy
      log = "Set worker to #{data['x']}, #{data['y']}"
      begin
        Celluloid::Actor[:game].set_free_worker_to_xy(user, data['town_id'], data['x'], data['y'])
        type = op
      rescue OrbError => log_msg
        log = log_msg
        type = :error
      end
      Log.push user, log, type
    when :free_worker
      log = "Set worker free on #{data['x']}, #{data['y']}"
      begin
        Celluloid::Actor[:game].free_worker user, data['town_id'], data['x'], data['y']
        type = op
      rescue OrbError => log_msg
        log = log_msg
        type = :error
      end
      Log.push user, log, type
    else
      LogBox.error('Unknown op', user)
    end
  end
end
