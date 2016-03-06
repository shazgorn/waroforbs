class Map
  attr_accessor :ul
  SIZE = nil
  CELL_DIM = 40
  BLOCK_DIM = 10
  BLOCK_DIM_PX = CELL_DIM * BLOCK_DIM
  BLOCKS_IN_MAP_DIM = 5
  MAX_CELL_IDX = BLOCK_DIM * BLOCKS_IN_MAP_DIM - 1
  MAP_CELLS_RANGE = (0..MAX_CELL_IDX)
  SHIFT = 1000

  def initialize
    @ul = Hash.new
  end

  # generate map
  def create_canvas_blocks(size = BLOCKS_IN_MAP_DIM)
    size.times do |block_x|
      size.times do |block_y|
        create_canvas_block(block_x, block_y)
      end
    end
  end
  
  def create_canvas_block(block_x, block_y, canvas_dim = BLOCK_DIM_PX, cell_dim = CELL_DIM)
    canvas = Magick::Image.new canvas_dim, canvas_dim
    canvas_y = 0
    while canvas_y < canvas_dim
      canvas_x = 0
      while canvas_x < canvas_dim
        n = Random.rand 10
        case n
        when 1, 2, 3, 4
          path = "./img/bg_grass_#{n}.png"
        else
          path = './img/bg_grass_1.png'
        end
        cell = Magick::ImageList.new path
        cell_dim.times do |x|
          cell_dim.times do |y|
            canvas.pixel_color(canvas_x + x, canvas_y + y, cell.pixel_color(x, y))
          end
        end
        canvas_x += cell_dim
      end
      canvas_y += cell_dim
    end
    #see map.coffee::addBlocks
    canvas_path = "./img/bg/bg_#{block_x}_#{block_y}.png"
    canvas.write canvas_path
    puts "write to #{canvas_path}"
  end
  
  def has?(x, y)
    [x, y].count{|c| (MAP_CELLS_RANGE).include? c} == 2
  end

  # coordinates to hash
  def c2h(x, y)
    x*SHIFT + y
  end

  def h2c(h)
    {:x => (h / SHIFT).to_i, :y => h % SHIFT}
  end
  
  def at(x, y)
    @ul[c2h(x, y)]
  end
  
  def place(unit, x=0, y=0, pos=c2h(x,y))
    @ul[pos] = unit
    unit.pos = pos
    unit.x = x
    unit.y = y
  end

  def place_at_random(unit)
    while true
      x = Random.rand(MAX_CELL_IDX)
      y = Random.rand(MAX_CELL_IDX)
      pos = c2h(x, y)
      if @ul[pos].nil?
        place(unit, x, y, pos)
        break
      end
    end
  end

  def move_by(unit, dx, dy)
    new_x = unit.x + dx
    new_y = unit.y + dy
    new_pos = c2h(new_x, new_y)
    if @ul[new_pos].nil? && has?(new_x, new_y) && [dx, dy].count{|c| (-1..1).include? c} == 2
      unit.x = new_x
      unit.y = new_y
      @ul.delete unit.pos
      unit.pos = new_pos
      @ul[new_pos] = unit
    end
  end

  def remove(unit)
    @ul.delete unit.pos
  end

end