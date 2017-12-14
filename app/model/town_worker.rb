class TownWorker
  attr_reader :type
  attr_accessor :x, :y

  ##
  # Worker position in province 1,2,3. Show worker in province bar and select which workers goes where

  def initialize(pos)
    @pos = pos
    @x = nil
    @y = nil
    # collecting resource type
    @type = nil
    @res_title = nil
    @profession = nil # occupation
    @start_time = nil
    @finish_time = nil
    @production_time = nil
    @delivery_time = nil
    # production + delivery time
    @total_time = nil
    @remaining_time = nil
    start_res_collection
  end

  def to_hash()
    {
      'pos' => @pos,
      'x' => @x,
      'y' => @y,
      'type' => @type,
      'res_title' => @res_title,
      'profession' => @profession,
      'start_time' => @start_time,
      'finish_time' => @finish_time,
      'production_time' => @production_time,
      'delivery_time' => @delivery_time,
      'total_time' => @total_time,
      'remaining_time' => @remaining_time,
    }
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
  end

  ##
  # TODO: Reset time on building upgrade

  def start_res_collection(res_type = :gold, distance = 1, production_building_level = 0, roads_level = 0)
    raise OrbError, 'res_type is nil' if res_type.nil?
    @type = res_type
    @profession = I18n.t(Config.get('resource')[@type.to_s]['profession'])
    @res_title = I18n.t(res_type)
    res_info = Config.get('resource')[@type.to_s]
    @production_time = (res_info['production_time'] * (100 - production_building_level) / 100).to_i
    @delivery_time = (res_info['delivery_time'] * distance * (100 - roads_level) / 100).to_i
    @total_time = @production_time + @delivery_time
    @start_time = Time.now
    @finish_time = @start_time + @total_time
    @remaining_time = @total_time
  end

  def clear
    @x = @y = nil
    start_res_collection
  end

  # check if it`s time to collect sto^Wresource
  def check_res
    if @finish_time && Time.now > @finish_time
      @finish_time += @total_time
      return true
    else
      @remaining_time = @finish_time - Time.now
    end
    return false
  end
end
