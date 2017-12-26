require 'config'

RSpec.describe Config, "test" do
  it 'barracs' do
    bcg = BuildingCostGenerator.new(Config[:buildings])
    type = :barracs
    bcg.generate_building_cost(type)
    cost = Config[:buildings][type][:cost]
    level = 1
    expect(cost[level][:time]).to eq(Config[:buildings][type][:cost][:formula][level][:time])
    expect(cost[level][:res][:gold]).to eq(10)
    expect(cost[level][:res][:wood]).to eq(2)
    level = 2
    expect(cost[level][:time]).to eq(Config[:buildings][type][:cost][:formula][level][:time])
    expect(cost[level][:res][:gold]).to eq(20)
    expect(cost[level][:res][:wood]).to eq(4)
    level = 3
    expect(cost[level][:res][:gold]).to eq(30)
    expect(cost[level][:res][:wood]).to eq(6)
  end
end
