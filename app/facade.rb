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
      if res[:error]
        LogBox.error(res[:error], user)
      else
        LogBox.attack(res, user)
        # LogBox.defence(res, defender)
        user_data[user_data_key].merge!(res)
      end
      # set_def_data users, res
    when :new_random_infantry
      Celluloid::Actor[:game].new_random_infantry(user)
      user_data[user_data_key][:active_unit_id] = user.active_unit_id
    # when :new_town
    #   begin
    #     Celluloid::Actor[:game].new_town user, user.active_unit_id
    #     log = 'New town has been settled'
    #     type = op
    #   end
    #   Log.push user, log, type
    when :dismiss
      unit_id = data['unit_id']
      begin
        Celluloid::Actor[:game].dismiss user, unit_id
        log = "Unit ##{unit_id} dismissed"
        type = op
      rescue OrbError => log_msg
        log = log_msg
        type = :error
      end
      Log.push(type, log, user)
    when :restart
      Celluloid::Actor[:game].restart token
      dispatch_units
    when :build
      begin
        res = Celluloid::Actor[:game].build user, data['building'].to_sym
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
      Log.push(type, log, user)
    when :create_default_company
      res = Celluloid::Actor[:game].create_company user, :new
      if res.nil?
        log = "Unable to create more companies. Limit reached."
      else
        log = "Infantry created"
      end
      Log.push user, log, op
    when :create_company
      res = Celluloid::Actor[:game].create_company user
      if res.nil?
        log = "Unable to create Infantry"
      else
        log = "Infantry created"
      end
      Log.push user, log, op
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
    when :add_squad_to_company
      log = "Squad added"
      begin
        res = Celluloid::Actor[:game].add_squad_to_company user, data['town_id'], data['company_id']
        type = op
      rescue OrbError => log_msg
        log = log_msg
        type = :error
      end
      Log.push user, log, type
    when :spawn_orb
      Celluloid::Actor[:game].spawn_orb data['color'].to_sym
    else
      LogBox.error('Unknown op', user)
    end
  end
end
