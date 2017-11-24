class TownWorker
  attr_reader :type
  attr_accessor :x, :y

  def initialize
    @x = nil
    @y = nil
    # collecting resource type
    @type = nil
    @start_time = nil
    @finish_time = nil
    # time to collect
    @ttc = nil
    start_default_res_collection
  end

  def to_hash()
    {
      'x' => @x,
      'y' => @y,
      'type' => @type,
      'start_time' => @start_time,
      'finish_time' => @finish_time,
      'ttc' => @ttc,
    }
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
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
