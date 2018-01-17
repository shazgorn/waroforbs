class SocketWriter
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  finalizer :my_finalizer

  attr_writer :token

  def initialize(websocket, name)
    @name = name
    @websocket = websocket
    @token = nil
    subscribe('send_units_to_user', :send_units)
  end

  def get_units_json_for_user user
    units = Actor[:game].all_units_for_user user
    units_json = {}
    units.each do |id, unit|
      if user.id == unit.user_id
        units_json[id] = unit.to_hash
      else
        units_json[id] = unit.to_enemy_hash
      end
    end
    units_json
  end

  def make_result(args)
    res = {}
    user = nil
    if @token
      ## user should be inited at this point ???
      user = Actor[:game].get_user_by_token(@token)
    end
    # this is our guy. Prepare data for owner of this socket
    if args[:user_data] && args[:user_data].has_key?(@name)
      # user specific data
      user_data = args[:user_data][@name]
      if user_data[:error]
        res[:error] = user_data[:error]
        return res
      else
        res = user_data
        if user_data[:data_type] == :init_map
          res.merge!(
            {
              :map_shift => Map::SHIFT,
              :cell_dim_in_px => Map::CELL_DIM_PX,
              :block_dim_in_cells => Actor[:map].block_dim,
              :block_dim_in_px => Actor[:map].block_dim_px,
              :map_dim_in_blocks => Actor[:map].blocks_in_map_dim,
              :MAX_CELL_IDX => Actor[:map].max_cell_idx,
              :active_unit_id => user.active_unit_id,
              :user_id => user.id,
              :user_name => user.login,
              :cells => Actor[:map].tiles,
              :blocks => Actor[:map].blocks,
              :resource_info => {
                :gold => {
                  :title => I18n.t('res_gold_title'),
                  :description => I18n.t('res_gold_description'),
                  :action => false
                },
                :wood => {
                  :title => I18n.t('res_wood_title'),
                  :description => I18n.t('res_wood_description'),
                  :action => false
                },
                :stone => {
                  :title => I18n.t('res_stone_title'),
                  :description => I18n.t('res_stone_description'),
                  :action => false
                },
                :settlers => {
                  :title => I18n.t('res_settlers_title'),
                  :description => I18n.t('res_settlers_description'),
                  :action => true,
                  :action_label => I18n.t('res_settlers_action_label')
                }
              },
              :building_states => {
                :BUILDING_STATE_GROUND => Building::STATE_GROUND,
                :BUILDING_STATE_IN_PROGRESS => Building::STATE_IN_PROGRESS,
                :BUILDING_STATE_COMPLETE => Building::STATE_COMPLETE,
                :BUILDING_STATE_CAN_UPGRADE => Building::STATE_CAN_UPGRADE
              },
              :building_descriptions => I18n.t('BuildingDescriptions')
            }
          )
        end
      end
    else
      # for everyone else
      res = {
        :data_type => :units,
      }
    end
    if user
      res.merge!(
        {
          :units => get_units_json_for_user(user),
          :logs => Actor[:game].get_current_logs_by_user(user),
          :user_unit_count => Actor[:game].unit_count(user),
          :user_unit_limit => Actor[:game].unit_limit(user),
          :actions => user.actions,
          :turn => Actor[:turn_counter].turns
        }
      )
    end
    res
  end

  ##
  # args => {:user_data => {key => data}}
  # writer must check the key and send data to to socket on match
  # data has :op, :log, :token etc

  def send_units(topic, args)
    unless @token
      error 'No token is set in writer ' + @name
      return
    end
    res = make_result(args)
    if res
      @websocket << JSON.generate(res)
    end
    res
    # rescue Reel::SocketError
    #   info "Ws client disconnected from #{@name} "
    #   terminate
  end

  def my_finalizer
    info "Writer #{@name} final"
    @websocket << JSON.generate({:data_type => :close})
  end
end
