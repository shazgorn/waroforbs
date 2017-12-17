require 'time_helper'

# status = 0 can be built
# status = 1 in progress
# status = 2 already build
class Building
  include TimeHelper

  attr_reader :cost_res, :name, :status, :level, :title

  STATE_GROUND = 1
  STATE_IN_PROGRESS = 2
  STATE_COMPLETE = 3
  STATE_CAN_UPGRADE = 4

  def initialize
    @status = STATE_GROUND
    @build_label = I18n.t('Build')
    # time to build (remaining time)
    @ttb = nil
    @start_time = nil
    @finish_time = nil
    @level = 0
    @max_level = Config['buildings'][@name]['max_level'].to_i
    init_cost
  end

  ##
  # Init cost for next level

  def init_cost
    if @level + 1 <= @max_level
      cost = Config['buildings'][@name]['cost'][@level + 1]
      @cost_time = cost['time']
      @cost_res = cost['res']
      @ttb_string = seconds_to_hm(@cost_time)
    end
  end

  def to_hash()
    check_build
    {
      'cost_res' => @cost_res,
      'cost_time' => @cost_time,
      'finish_time' => @finish_time,
      'name' => @name,
      'title' => @title,
      'start_time' => @start_time,
      'status' => @status,
      'ttb' => @ttb,
      'ttb_string' => @ttb_string,
      'level' => @level,
      'build_label' => @build_label,
      'actions' => actions
    }
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
  end

  def enough_resources? avail_resources
    @cost_res.each{|res_name, res_count|
      if res_count > 0 && (!avail_resources.has_key?(res_name.to_sym) || avail_resources[res_name.to_sym] < res_count)
        return false
      end
    }
    true
  end

  ##
  # Start construction
  # return true if construction started

  def build
    raise UnableToComplyBuildingInProgress if @status == STATE_IN_PROGRESS
    raise MaxBuildingLevelReached if @level == @max_level
    check_build
    @status = STATE_IN_PROGRESS
    if @cost_time
      @start_time = Time.now()
      @finish_time = @start_time + @cost_time
      update_ttb
    end
    true
  end

  ##
  # Check if building status can be set to STATE_COMPLETE from STATE_IN_PROGRESS
  # should be used on every read action

  def check_build
    case @status
    when STATE_IN_PROGRESS
      if Time.now() > @finish_time
        @finish_time = nil
        @start_time = nil
        @ttb = nil
        @level += 1
        init_cost
        if @level < @max_level
          @status = STATE_CAN_UPGRADE
          @build_label = I18n.t('Upgrade')
        else
          @status = STATE_COMPLETE
        end
      else
        update_ttb
      end
    end
  end

  def update_ttb
    @ttb = (@finish_time - Time.now()).round(0)
    @ttb_string = seconds_to_hm @ttb
  end

  def built?
    check_build
    @status == STATE_COMPLETE || @status == STATE_CAN_UPGRADE
  end

  def in_progress?
    @status == STATE_IN_PROGRESS
  end

  def destroy
    @status = STATE_GROUND
    @build_label = I18n.t('Build')
  end

  def actions
    []
  end
end
