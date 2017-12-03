require 'time_helper'

# status = 0 can be built
# status = 1 in progress
# status = 2 already build
class Building
  include TimeHelper

  attr_reader :cost_res, :name

  STATE_CAN_BE_BUILT = 1
  STATE_IN_PROGRESS = 2
  STATE_BUILT = 3

  def initialize
    @status = STATE_CAN_BE_BUILT
    # time to build (remaining time)
    @ttb = nil
    @ttb_string = nil
    @cost_time = nil
    @cost_res = nil
    @start_time = nil
    @finish_time = nil
    @cost_time = Config.get(@name)['cost_time']
    @cost_res = Config.get(@name)['cost_res']
    @ttb_string = seconds_to_hm(@cost_time)
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

  def build
    raise BuildingAlreadyInProgress, 'Building already in progress' if @status == STATE_IN_PROGRESS
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
  # Check if building status can be set to STATE_BUILT from STATE_IN_PROGRESS
  # should be used on every read action

  def check_build
    case @status
    when STATE_CAN_BE_BUILT

    when STATE_IN_PROGRESS
      if Time.now() > @finish_time
        @status = STATE_BUILT
        @finish_time = nil
        @start_time = nil
        @ttb = nil
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
    @status == STATE_BUILT
  end

  def in_progress?
    @status == STATE_IN_PROGRESS
  end

  def destroy
    @status = STATE_CAN_BE_BUILT
  end

  def actions
    []
  end
end

class Tavern < Building
  def initialize
    @name = 'tavern'
    @title = I18n.t('Tavern')
    super
  end
end

class Barracs < Building
  SQUAD_COST = 10

  def initialize
    @name = 'barracs'
    @title = I18n.t('Barracs')
    super
  end

  def actions
    if built?
      [HireSwordsmanAction.new(true)]
    else
      [HireSwordsmanAction.new(false)]
    end
  end
end
