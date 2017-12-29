require 'game'
require 'map'

RSpec.describe Map, "testing", :map => true do
  around do |ex|
    Celluloid.boot
    Token.drop
    Celluloid::Actor[:map] = Map.new(true, 'map_test')
    ex.run
    Celluloid.shutdown
  end

  it 'is out of map' do
    expect(Celluloid::Actor[:map].has?(1,1)).to be true
    expect(Celluloid::Actor[:map].has?(0,0)).to be false
    expect(Celluloid::Actor[:map].has?(Map::MAX_CELL_IDX, Map::MAX_CELL_IDX)).to be true
    expect(Celluloid::Actor[:map].has?(Map::MAX_CELL_IDX + 1, Map::MAX_CELL_IDX + 1)).to be false
  end

  it 'is God of Random' do
    greatest_x = 0
    greatest_y = 0
    10000.times do |i|
      xy = Celluloid::Actor[:map].get_rand_coords
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
end
