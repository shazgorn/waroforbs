require 'celluloid/current'
require 'fileutils'
require 'json'
require 'yaml'
require 'mini_magick'

require 'config'
require 'map_tile'

class Map
  include Celluloid::Internals::Logger
  attr_reader :cells
  attr_accessor :ul

  CELL_DIM_PX = 32 # how may pixels in one cell (one side)
  BLOCK_DIM = Config.get('BLOCK_DIM') # how many cells in block (one side)
  BLOCK_DIM_PX = CELL_DIM_PX * BLOCK_DIM # how many pixels in one block (one side)
  BLOCKS_IN_MAP_DIM = Config.get('BLOCKS_IN_MAP_DIM')
  MAX_CELL_IDX = BLOCK_DIM * BLOCKS_IN_MAP_DIM
  MAP_CELLS_RANGE = (1..MAX_CELL_IDX)
  SHIFT = 1000

  ##
  # Write test maps to separate files
  # +generate+ map

  def initialize(generate = false, file_name = 'map')
    @data_path = "./data/#{file_name}.dat"
    @cells = {}
    @cells_bg = {
      1 => {
        :path => "./" + Config.get('img_path') + "grass.png",
        :type => :grass
      },
      2 => {
        :path => "./" + Config.get('img_path') + "grass.png",
        :type => :grass
      },
      3 => {
        :path => "./" + Config.get('img_path') + "grass.png",
        :type => :grass
      },
      4 => {
        :path => "./" + Config.get('img_path') + "grass.png",
        :type => :grass
      },
      5 => {
        :path => "./" + Config.get('img_path') + "oak.png",
        :type => :tree
      },
      6 => {
        :path => "./" + Config.get('img_path') + "betula.png",
        :type => :tree
      },
      7 => {
        :path => "./" + Config.get('img_path') + "picea.png",
        :type => :mountain
      }
    }
    JSON.dump_default_options[:max_nesting] = 10
    JSON.load_default_options[:max_nesting] = 10
    if generate || !File.exist?(@data_path)
      generate_map
    else
      file = File.open(@data_path, "r")
      @cells = Marshal.load(file)
    end
  end

  def generate_map
    start = Time.now.to_f
    info "Generate map"
    create_canvas_blocks
    finish = Time.now.to_f
    diff = finish - start
    info "Map generated in %f seconds" % diff.to_f
    File.open(@data_path, "w") do |file|
      file.print Marshal.dump(@cells)
      info "Map data saved to %s" % @data_path
    end
  end

  # generate map blocks
  def create_canvas_blocks(size = BLOCKS_IN_MAP_DIM)
    (1..size).each do |block_x|
      (1..size).each do |block_y|
        create_canvas_block(block_x, block_y)
      end
    end
  end

  def create_canvas_block(block_x, block_y, canvas_dim = BLOCK_DIM_PX, cell_dim_px = CELL_DIM_PX)
    MiniMagick::Tool::Montage.new do |builder|
      builder.geometry "+0+0"
      canvas_y = 0
      cell_y = ((block_y - 1) * BLOCK_DIM + 1)
      while canvas_y < canvas_dim
        canvas_x = 0
        cell_x = ((block_x - 1) * BLOCK_DIM + 1)
        while canvas_x < canvas_dim
          n = Random.rand 20
          n = 1 unless @cells_bg.has_key?(n)
          cell_bg = @cells_bg[n]
          map_cell = MapTile.new(cell_x, cell_y, cell_bg[:type])
          builder << cell_bg[:path]
          @cells["#{cell_x}_#{cell_y}"] = map_cell
          canvas_x += cell_dim_px
          cell_x += 1
        end
        canvas_y += cell_dim_px
        cell_y += 1
      end
      #see map.coffee::addBlocks
      canvas_path = "./" + Config.get('img_path') + "bg/bg_#{block_x}_#{block_y}.png"
      builder << canvas_path
      info "write to #{canvas_path}"
    end
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
    x = Random.rand(1..MAX_CELL_IDX)
    y = Random.rand(1..MAX_CELL_IDX)
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
    raise OrbError, "No cell for #{x},#{y}" unless cell
    cell.type
  end

end
