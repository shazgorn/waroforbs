require 'game'

RSpec.describe Chest, "testing" do
  it 'setting default res' do
    c = Chest.new(1, 1)
    c.inventory[:gold] = 0
    c.inventory[:wood] = 0
    c.inventory[:stone] = 0
    c.check_inventory
    expect(c.inventory[:gold]).to be > 0
    expect(c.inventory[:wood]).to eq(0)
    expect(c.inventory[:stone]).to eq(0)
  end
end
