require 'game'

RSpec.describe Town, "testing" do
  it 'is setting worker' do
    user = User.new('towner')
    town = Town.new(1, 1, user)
    pos = 1
    w = town.get_worker_by_pos(pos)
    new_x = 2
    new_y = 2
    expect(Config[:resource][:gold][:production_building]).to eq(:factory)
    town.set_worker_to(pos, new_x, new_y, :gold)
    expect(w.x).to eq(new_x)
    expect(w.y).to eq(new_y)
    new_x = 2
    new_y = 3
    town.set_worker_to(pos, new_x, new_y, :gold)
    expect(w.x).to eq(new_x)
    expect(w.y).to eq(new_y)
  end

  it 'is updating worker when construction is compelete' do
    user = User.new('towner')
    town = Town.new(1, 1, user)
    pos = 1
    w = town.get_worker_by_pos(pos)
    w.start_res_collection(:wood, 1)
    expect(w.total_time).to_not be_nil
    expect(w.remaining_time).to_not be_nil
    town.build(:sawmill)
  end
end
