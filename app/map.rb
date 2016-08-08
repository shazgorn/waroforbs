require 'fileutils'
require 'json'

class MapCell < JSONable
  attr_accessor :x, :y, :type, :unit
  def initialize(x = nil, y = nil, type = nil, unit = nil)
    @x = x
    @y = y
    # type - :grass, :tree
    @type = type
    @unit = unit
  end
end

class Map
  attr_reader :cells
  attr_accessor :ul
  SIZE = nil
  CELL_DIM_PX = 40
  BLOCK_DIM = 10
  BLOCK_DIM_PX = CELL_DIM_PX * BLOCK_DIM
  BLOCKS_IN_MAP_DIM = 2
  MAX_CELL_IDX = BLOCK_DIM * BLOCKS_IN_MAP_DIM - 1
  MAP_CELLS_RANGE = (0..MAX_CELL_IDX)
  SHIFT = 1000

  def initialize(generate = false)
    @path = '/home/user/public_html/waroforbs/map.dat'
    @cells = {}
    JSON.dump_default_options[:max_nesting] = 10
    JSON.load_default_options[:max_nesting] = 10
    if generate
      create_canvas_blocks
      File.open(@path, "w") do |file|
        file.print @cells.to_json
      end
    else
      file = File.open(@path, "r")
      @cells = JSON.load(file)
    end
  end

  # generate map
  def create_canvas_blocks(size = BLOCKS_IN_MAP_DIM)
    size.times do |block_x|
      size.times do |block_y|
        create_canvas_block(block_x, block_y)
      end
    end
  end
  
  def create_canvas_block(block_x, block_y, canvas_dim = BLOCK_DIM_PX, cell_dim_px = CELL_DIM_PX)
    FileUtils::mkdir_p './img/bg'
    canvas = Magick::Image.new canvas_dim, canvas_dim
    canvas_y = 0
    cell_y = block_y * BLOCK_DIM
    while canvas_y < canvas_dim
      canvas_x = 0
      cell_x = block_x * BLOCK_DIM
      while canvas_x < canvas_dim
        map_cell = MapCell.new(cell_x, cell_y)
        n = Random.rand 10
        case n
        when 1, 2, 3, 4
          path = "./img/bg_grass_#{n}.png"
          map_cell.type = :grass
        when 5
          path = "./img/bg_tree_on_grass.png"
          map_cell.type = :tree
        when 6
          path = "./img/bg_oak_on_grass_1.png"
          map_cell.type = :tree
        when 7
          path = "./img/bg_mountain_on_grass.png"
          map_cell.type = :mountain
        else
          path = './img/bg_grass_1.png'
          map_cell.type = :grass
        end
        @cells["#{cell_x}_#{cell_y}"] = map_cell
        cell = Magick::ImageList.new path
        cell_dim_px.times do |x|
          cell_dim_px.times do |y|
            canvas.pixel_color(canvas_x + x, canvas_y + y, cell.pixel_color(x, y))
          end
        end
        canvas_x += cell_dim_px
        cell_x += 1
      end
      canvas_y += cell_dim_px
      cell_y += 1
    end
    #see map.coffee::addBlocks
    canvas_path = "./img/bg/bg_#{block_x}_#{block_y}.png"
    canvas.write canvas_path
    puts "write to #{canvas_path}"
  end

  # check if coordinates are valid, alias may be
  def has?(x, y)
    [x, y].count{|c| (MAP_CELLS_RANGE).include? c} == 2
  end

  alias valid? has?

  # coordinates to hash
  def c2h(x, y)
    x*SHIFT + y
  end

  def h2c(h)
    {:x => (h / SHIFT).to_i, :y => h % SHIFT}
  end

  def get_rand_coords
    x = Random.rand(MAX_CELL_IDX)
    y = Random.rand(MAX_CELL_IDX)
    {:x => x, :y => y}
  end

  def d_include?(dx, dy)
    [dx, dy].count{|c| (-1..1).include? c} == 2
  end

  def adj_cells?(x1, y1, x2, y2)
    (-1..1).include?(x1 - x2) && (-1..1).include?(y1 - y2)
  end

  # max distance
  def max_diff(x1, y1, x2, y2)
    [(x1 - x2).abs(), (y1 - y2).abs()].max
  end

  def cell_at(x, y)
    @cells["#{x}_#{y}"]
  end

  def cell_type_at(x, y)
    cell = cell_at(x, y)
    cell['@type'].to_sym
  end

end
