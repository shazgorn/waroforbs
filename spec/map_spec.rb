require 'game'

RSpec.describe Map, "testing", :map => true do
  around do |ex|
    Celluloid.boot
    Token.drop_all
    Celluloid::Actor[:map] = Map.new(true, 'map_test')
    ex.run
    Celluloid.shutdown
  end

  let (:map) {Celluloid::Actor[:map]}

  it 'is out of map' do
    expect(map.has?(1,1)).to be true
    expect(map.has?(0,0)).to be false
    expect(map.has?(Map::MAX_CELL_IDX, Map::MAX_CELL_IDX)).to be true
    expect(map.has?(Map::MAX_CELL_IDX + 1, Map::MAX_CELL_IDX + 1)).to be false
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
    expect(greatest_x).to eq(Map::MAX_CELL_IDX)
    expect(greatest_y).to eq(Map::MAX_CELL_IDX)
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
    expect(map.axis_range_adj Map::MAX_CELL_IDX, 1).to eq((Map::MAX_CELL_IDX-1..Map::MAX_CELL_IDX))
  end
end
