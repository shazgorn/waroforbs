require 'building_container'

class TownWorker
  attr_reader :type
  attr_accessor :x, :y, :total_time, :remaining_time

  ##
  # Worker position in province 1,2,3. Show worker in province bar and select which workers goes where

  def initialize(pos, bc)
    @pos = pos
    @bc = bc
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
    @distance = nil
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
  # Recalculate time after every resource collection
  # because buildings can be upgraded, no hard work i think

  def start_res_collection(res_type, distance)
    @type = res_type
    @distance = distance
    @res_title = I18n.t(res_type)
    @profession = I18n.t(Config['resource'][@type.to_s]['profession'])
    @res_info = Config['resource'][@type.to_s]
    # TODO: max_level + 1 - production_level
    @production_time = @res_info['production_time'] * (11 - @bc.get_levels(@type)[0])
    @delivery_time = @res_info['delivery_time'] * @distance * (11 - @bc.get_levels(@type)[1])
    @total_time = @production_time + @delivery_time
    @start_time = Time.now
    @finish_time = @start_time + @total_time
    @remaining_time = @total_time
  end

  ##
  # deprecated

  def clear
    @x = @y = nil
    start_res_collection
  end

  # check if it`s time to collect sto^Wresource
  def collect_res
    if @finish_time && Time.now > @finish_time
      start_res_collection(@type, @distance)
      return 1
    end
    # what if tick is less ?
    @remaining_time = @finish_time - Time.now
    0
  end
end
