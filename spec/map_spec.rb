require 'map'

RSpec.describe Map, "testing" do
  it 'is out of map' do
    map = Map.new(true)
    blocks = Config.get('BLOCKS_IN_MAP_DIM')
    expect(map.has?(1,1)).to be true
    expect(map.has?(0,0)).to be false
    puts Map::MAX_CELL_IDX
    expect(map.has?(Map::MAX_CELL_IDX, Map::MAX_CELL_IDX)).to be true
    expect(map.has?(Map::MAX_CELL_IDX + 1, Map::MAX_CELL_IDX + 1)).to be false
  end
end
