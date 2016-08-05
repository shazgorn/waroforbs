# status = 0 can be built
# status = 1 in progress
# status = 2 already build
class Building
  attr_reader :cost_res

  STATE_CAN_BE_BUILT = 0
  STATE_IN_PROGRESS = 1
  STATE_BUILT = 2

  def initialize
    @status = STATE_CAN_BE_BUILT
    # time to build (remaining time)
    @ttb = nil
    @ttb_string = nil
    @cost_time = nil
    @cost_res = {
      :gold => 0,
      :wood => 0,
      :stone => 0
    }
    @start_time = nil
    @finish_time = nil
  end

  def build
    raise OrbError, 'Building already in progress' if @status == STATE_IN_PROGRESS
    @status = STATE_IN_PROGRESS
    if @cost_time
      @start_time = Time.now()
      @finish_time = @start_time + @cost_time
    end
    true
  end

  def enough_resources? avail_resources
    @cost_res.each{|res_name, res_count|
      if res_count > 0 && (!avail_resources.has_key?(res_name) || avail_resources[res_name] < res_count)
        return false
      end
    }
    true
  end

  def built?
    @status == STATE_BUILT
  end

  def in_progress?
    @status == STATE_IN_PROGRESS
  end

  def actions
    []
  end

  def seconds_to_hm t
    minutes = (t / 60).round(0)
    seconds = t % 60
    if seconds < 10
      seconds = "0#{seconds}"
    end
    "#{minutes}:#{seconds}"
  end

  def to_hash()
    if in_progress?
      if Time.now() > @finish_time
        @status = STATE_BUILT
        @finish_time = nil
        @start_time = nil
        @ttb = nil
      else
        @ttb = (@finish_time - Time.now()).round(0)
        @ttb_string = seconds_to_hm @ttb
      end
    end
    hash = {}
    self.instance_variables.each do |var|
      hash[var] = self.instance_variable_get var
    end
    hash
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
  end
end

class Tavern < Building
  def initialize
    super
    @name = 'Tavern'
  end
end

class Barracs < Building
  COMPANY_COST = 20
  SQUAD_COST = 10

  def initialize
    super
    @name = 'Barracs'
    @cost_time = 3
    @cost_res[:gold] = 20
    @cost_res[:wood] = 5
    @ttb_string = seconds_to_hm @cost_time
  end

  def actions
    if built?
      [:create_default_company]
    else
      []
    end
  end
end

class BannerShop < Building
  BANNER_COST = 10

  def initialize
    super
    @name = 'Banner Shop'
    @cost_time = 3
    @cost_res[:gold] = 10
    @ttb_string = seconds_to_hm @cost_time
  end
end
