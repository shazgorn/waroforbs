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
    # time to collect
    @ttc = nil
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
      'ttc' => @ttc,
    }
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
  end

  def start_res_collection(res_type = :gold, distance = 1)
    raise OrbError, 'res_type is nil' if res_type.nil?
    @type = res_type
    @profession = I18n.t(Config.get('resource')[@type.to_s]['profession'])
    @res_title = I18n.t(res_type)
    res_info = Config.get('resource')[@type.to_s]
    @ttc = res_info['production_time'] + res_info['delivery_time'] * distance
    @start_time = Time.now
    @finish_time = @start_time + @ttc
  end

  def clear
    @x = @y = nil
    start_res_collection
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
