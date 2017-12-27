require 'exception'

##
# Process request object and pass it to the game actor

class Facade
  include Celluloid
  include Celluloid::Internals::Logger
  include Celluloid::Notifications

  attr_reader :user
  finalizer :my_finalizer

  def initialize
    @user = nil
  end

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
    unless @user
      # add expiration time for token (one day)
      @user = Celluloid::Actor[:game].get_user_by_token(token)
      if @user
        publish 'user_auth', @user.id
      end
    end
    if @user && data.has_key?('unit_id')
      # remove duplicates of :active_unit_id setting in user_data?
      user_data[user_data_key][:active_unit_id] = @user.active_unit_id = data['unit_id'].to_i
    end
    make_action_on_op(op, user, data, user_data, user_data_key, token)
    if @user
      user_data[user_data_key][:actions] = @user.actions
      user_data[user_data_key][:user_glory] = @user.glory
      user_data[user_data_key][:user_max_glory] = @user.max_glory
    end
    user_data
  end

  def make_action_on_op(op, user, data, user_data, user_data_key, token)
    Celluloid::Actor[:turn_counter].make_turn
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
    when :give
      Celluloid::Actor[:game].give(user, data['from_id'].to_i, data['to_id'].to_i, data['inventory'])
    when :take
      Celluloid::Actor[:game].take(user, data['to_id'].to_i, data['from_id'].to_i, data['inventory'])
    when :attack
      Celluloid::Actor[:game].attack_by_user(user, user.active_unit_id, data['d_id'].to_i)
    when :settle_town
      Celluloid::Actor[:game].settle_town(user, user.active_unit_id)
    when :build
      Celluloid::Actor[:game].build(user, data['building'].to_sym)
    when :spawn_orb
      Celluloid::Actor[:game].spawn_orb(data['color'].to_sym)
    when :spawn_dummy_near
      Celluloid::Actor[:game].spawn_dummy_near(data['x'], data['y'])
    when :provoke_dummy_attack
      Celluloid::Actor[:game].provoke_dummy_attack()
    when :spawn_monolith_near
      Celluloid::Actor[:game].spawn_monolith_near(data['x'], data['y'])
    when :hire_unit
      Celluloid::Actor[:game].hire_unit(user, data['unit_type'])
    when :disband
      unit_id = data['unit_id']
      Celluloid::Actor[:game].disband user, unit_id
    when :restart
      Celluloid::Actor[:game].restart(user)
      user_data[user_data_key][:active_unit_id] = user.active_unit_id
    when :rename_unit
      Celluloid::Actor[:game].rename_unit(user, data['unit_id'], data['unit_name'])
    when :set_worker_to_xy
      Celluloid::Actor[:game].set_worker_to_xy(user, data['town_id'].to_i, data['worker_pos'].to_i, data['x'].to_i, data['y'].to_i)
    when :refill_squad
      # Not implemented!
      Celluloid::Actor[:game].refill_squad user, data['town_id'], data['unit_id']
    else
      LogBox.error('Unknown op', user)
    end
  end

  def my_finalizer
    if @user
      publish 'user_quit', @user.id
    end
  end
end
