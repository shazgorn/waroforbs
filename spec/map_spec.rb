require 'game'

class TestMap < Map
  attr_accessor :blocks_in_map_dim, :tiles, :blocks
end

RSpec.describe Map, "testing", :map => true do
  around do |ex|
    Celluloid.boot
    Token.drop_all
    Celluloid::Actor[:map] = TestMap.new(true, 'map_test')
    ex.run
    Celluloid.shutdown
  end

  let (:map) {Celluloid::Actor[:map]}

  it 'is out of map' do
    expect(map.has?(1,1)).to be true
    expect(map.has?(0,0)).to be false
    expect(map.has?(Celluloid::Actor[:map].max_cell_idx, Celluloid::Actor[:map].max_cell_idx)).to be true
    expect(map.has?(Celluloid::Actor[:map].max_cell_idx + 1, Celluloid::Actor[:map].max_cell_idx + 1)).to be false
  end

  it 'is God of Random' do
    greatest_x = 0
    greatest_y = 0
    10000.times do |i|
      xy = map.get_rand_coords
      x = xy[:x]
      y = xy[:y]
      greatest_x = x if x > greatest_x
      greatest_y = y if y > greatest_y
      expect(x > 0).to be true
      expect(y > 0).to be true
    end
    expect(greatest_x).to eq(Celluloid::Actor[:map].max_cell_idx)
    expect(greatest_y).to eq(Celluloid::Actor[:map].max_cell_idx)
  end

  it 'erate_each_tile' do
    tiles = 0
    map.each_tile{|tile|
      tiles += 1
    }
    expect(tiles).to eq(Config['BLOCK_DIM'] ** 2 * Config['BLOCKS_IN_MAP_DIM'] ** 2)
  end

  it 'axis range adj' do
    expect(map.axis_range_adj 5, 1).to eq((4..6))
    expect(map.axis_range_adj 1, 1).to eq((1..2))
    expect(map.axis_range_adj Celluloid::Actor[:map].max_cell_idx, 1).to eq((Celluloid::Actor[:map].max_cell_idx-1..Celluloid::Actor[:map].max_cell_idx))
  end

  it 'map widening' do
    expect(Celluloid::Actor[:map].check_map).to be true
    Celluloid::Actor[:map].init_from_config(Celluloid::Actor[:map].blocks_in_map_dim + 1, Config['BLOCK_DIM'])
    Celluloid::Actor[:map].tiles = {}
    Celluloid::Actor[:map].blocks = {}
    expect(Celluloid::Actor[:map].check_map).to be false
  end
end
