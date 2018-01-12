require 'celluloid/current'
require 'fileutils'
require 'json'
require 'yaml'
require 'mini_magick'

require 'config'
require 'map_tile'

class Map
  include Celluloid
  include Celluloid::Internals::Logger

  attr_reader :tiles, :blocks, :blocks_in_map_dim, :max_cell_idx, :block_dim, :block_dim_px
  attr_accessor :ul

  CELL_DIM_PX = 32 # how may pixels in one cell (one side)
  SHIFT = 1000

  ##
  # Write test maps to separate files
  # +generate+ map

  def initialize(generate = false, file_name = 'map')
    @file_name = file_name
    @data_path = "./data/#{file_name}.dat"
    @blocks = {}
    @tiles = {}
    @tiles_info = {
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
        :type => :tree
      },
      8 => {
        :path => "./" + Config.get('img_path') + "mountain.png",
        :type => :mountain
      }
    }
    JSON.dump_default_options[:max_nesting] = 10
    JSON.load_default_options[:max_nesting] = 10
    init_from_config Config['BLOCKS_IN_MAP_DIM'], Config['BLOCK_DIM']
    if generate || !File.exist?(@data_path)
      generate_map
    else
      file = File.open(@data_path, "r")
      data = Marshal.load(file)
      @tiles = data[:tiles]
      @blocks = data[:blocks]
      check_map
    end
  end

  def init_from_config blocks_in_map_dim, block_dim
    @blocks_in_map_dim = blocks_in_map_dim
    @block_dim = block_dim # how many cells in block (one side)
    @block_dim_px = CELL_DIM_PX * @block_dim # how many pixels in one block (one side)
    @max_cell_idx = @block_dim * @blocks_in_map_dim
    @map_cells_range = (1..@max_cell_idx) # coordinates range
  end

  ##
  # Check if loaded map is valid and is okay with current config and return true
  # regenerate the map otherwise and return false

  def check_map
    begin
      @map_cells_range.each do |y|
        @map_cells_range.each do |x|
          if @tiles[x].nil? || @tiles[x][y].nil?
            raise RuntimeError, "tile #{x},#{y} not found, regenerate the map"
          end
        end
      end
    rescue RuntimeError => e
      error e.message
      generate_map
      return false
    end
    true
  end

  def generate_map
    start = Time.now.to_f
    info "Generate map"
    @map_cells_range.each{|x|
      @tiles[x] = {}
      @map_cells_range.each{|y|
        n = Random.rand 20
        n = 1 unless @tiles_info.has_key?(n)
        @tiles[x][y] = MapTile.new(x, y, @tiles_info[n][:type], @tiles_info[n][:path])
        # puts "#{x}_#{y} #{@tiles_info[n][:type]}"
      }
    }
    create_canvas_blocks
    finish = Time.now.to_f
    diff = finish - start
    info "Map generated in %f seconds" % diff.to_f
    File.open(@data_path, "w") do |file|
      file.print Marshal.dump({:tiles => @tiles, :blocks => @blocks})
      info "Map data saved to %s" % @data_path
    end
  end

  # generate map blocks
  def create_canvas_blocks
    (1..@blocks_in_map_dim).each do |block_x|
      @blocks[block_x] = {}
      (1..@blocks_in_map_dim).each do |block_y|
        create_canvas_block(block_x, block_y)
      end
    end
  end

  def create_canvas_block(block_x, block_y)
    MiniMagick::Tool::Montage.new do |builder|
      builder.geometry "+0+0"
      canvas_y = 0
      cell_y = ((block_y - 1) * @block_dim + 1)
      while canvas_y < @block_dim_px
        canvas_x = 0
        cell_x = ((block_x - 1) * @block_dim + 1)
        while canvas_x < @block_dim_px
          builder << @tiles[cell_x][cell_y].path
          canvas_x += CELL_DIM_PX
          cell_x += 1
        end
        canvas_y += CELL_DIM_PX
        cell_y += 1
      end
      #see map.coffee::addBlocks
      block_path = "bg/bg_#{block_x}_#{block_y}_#{@file_name}.png"
      @blocks[block_x][block_y] = {:path => block_path}
      canvas_path = "./" + Config.get('img_path') + block_path
      builder << canvas_path
      info "write to #{canvas_path}"
    end
  end

  # check if coordinates are valid, alias may be
  def has?(x, y)
    [x, y].count{|c| @map_cells_range.include? c} == 2
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
    x = Random.rand(1..@max_cell_idx)
    y = Random.rand(1..@max_cell_idx)
    {:x => x, :y => y}
  end

  def get_rand_coords_near x, y, radius
    {
      :x => Random.rand(axis_range_adj(x, radius)),
      :y => Random.rand(axis_range_adj(y, radius))
    }
  end

  ##
  # axis - x or y coordinate
  # return range of valid coordianates around axis(point)

  def axis_range_adj axis, radius = 1
    left = axis - radius
    left = 1 if left < 1
    right = axis + radius
    right = @max_cell_idx if right > @max_cell_idx
    (left..right)
  end

  ##
  # Iterate over all adj cells around x, y

  def each_adj_near x, y
    (axis_range_adj y).each do |adj_y|
      (axis_range_adj x).each do |adj_x|
        unless x == adj_x && y == adj_y
          yield adj_x, adj_y
        end
      end
    end
  end

  def d_include?(dx, dy)
    [dx, dy].count{|c| (-1..1).include? c} == 2
  end

  def adj_cells?(x1, y1, x2, y2)
    (-1..1).include?(x1 - x2) && (-1..1).include?(y1 - y2)
  end

  def cell_at(x, y)
    @tiles[x][y] # ["#{x}_#{y}"]
  end

  def cell_type_at(x, y)
    cell_at(x, y).type
  end

  def each_tile
    @map_cells_range.each do |y|
      @map_cells_range.each do |x|
        yield @tiles[x][y]
      end
    end
  end
end
