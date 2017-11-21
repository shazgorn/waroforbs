class TownWorker < JSONable
  attr_reader :type
  attr_accessor :x, :y

  def initialize
    @x = nil
    @y = nil
    @type = nil
    @start_time = nil
    # time to collect
    @ttc = nil
    @finish_time = nil
    start_default_res_collection
  end

  def start_default_res_collection
    start_res_collection :gold
  end

  def start_res_collection res_type, distance = 1
    @type = res_type
    @ttc = Config.get('resource')[@type.to_s]['time_to_collect'] * distance
    @start_time = Time.now
    @finish_time = @start_time + @ttc
  end

  def clear
    @x = @y = nil
    start_default_res_collection
  end

  # check if it`s time to collect resource
  def check_res
    if @finish_time && Time.now > @finish_time
      @finish_time += @ttc
      return true
    end
    return false
  end
end
