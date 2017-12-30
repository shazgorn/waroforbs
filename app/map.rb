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

  attr_reader :tiles, :blocks
  attr_accessor :ul

  CELL_DIM_PX = 32 # how may pixels in one cell (one side)
  BLOCK_DIM = Config['BLOCK_DIM'] # how many cells in block (one side)
  BLOCK_DIM_PX = CELL_DIM_PX * BLOCK_DIM # how many pixels in one block (one side)
  BLOCKS_IN_MAP_DIM = Config.get('BLOCKS_IN_MAP_DIM')
  MAX_CELL_IDX = BLOCK_DIM * BLOCKS_IN_MAP_DIM
  MAP_CELLS_RANGE = (1..MAX_CELL_IDX)
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
    if generate || !File.exist?(@data_path)
      generate_map
    else
      # TODO write blocks
      file = File.open(@data_path, "r")
      data = Marshal.load(file)
      @tiles = data[:tiles]
      @blocks = data[:blocks]
    end
  end

  def generate_map
    start = Time.now.to_f
    info "Generate map"
    MAP_CELLS_RANGE.each{|x|
      @tiles[x] = {}
      MAP_CELLS_RANGE.each{|y|
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
  def create_canvas_blocks(size = BLOCKS_IN_MAP_DIM)
    (1..size).each do |block_x|
      @blocks[block_x] = {}
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
          builder << @tiles[cell_x][cell_y].path
          canvas_x += cell_dim_px
          cell_x += 1
        end
        canvas_y += cell_dim_px
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
    [x, y].count{|c| MAP_CELLS_RANGE.include? c} == 2
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

  def get_rand_coords_near x, y, radius
    x_left = x - radius
    x_left = 1 if x_left < 1
    y_left = y - radius
    y_left = 1 if y_left < 1
    x_right = x + radius
    x_right = MAX_CELL_IDX if x_right > MAX_CELL_IDX
    y_right = y + radius
    y_right = MAX_CELL_IDX if y_right > MAX_CELL_IDX
    x = Random.rand(x_left..x_right)
    y = Random.rand(y_left..y_right)
    {:x => x, :y => y}
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
    (1..MAX_CELL_IDX).each{|y|
      (1..MAX_CELL_IDX).each{|x|
        yield @tiles[x][y]
      }
    }
  end
end
