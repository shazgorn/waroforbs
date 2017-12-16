require 'game'

module CostHelper
  def check_level_plain(name, level)
    cost = CostParser.find_cost(name, level)
    expect(cost['time']).to eq(Config[name]['cost_levels'][level]['time'])
    expect(cost['res']['gold']).to eq(Config[name]['cost_levels'][level]['res']['gold'])
    expect(cost['res']['wood']).to eq(Config[name]['cost_levels'][level]['res']['wood'])
  end
end

RSpec.configure do |c|
  c.include CostHelper
end

RSpec.describe CostParser, "#testing" do
  it "plain" do
    name = 'factory'
    check_level_plain(name, 1)
    check_level_plain(name, 2)
    cost = CostParser.find_cost(name, 3)
    expect(cost['time']).to eq(Config[name]['cost_levels'][2]['time'])
    expect(cost['res']['gold']).to eq(Config[name]['cost_levels'][2]['res']['gold'])
    expect(cost['res']['wood']).to eq(Config[name]['cost_levels'][2]['res']['wood'])
  end

  it 'alg' do
    name = 'sawmill'
    cost = CostParser.find_cost(name, 1)
    expect(cost['time']).to eq(4)
    expect(cost['res']['gold']).to eq(5)
    expect(cost['res']['wood']).to eq(2)
    cost = CostParser.find_cost(name, 2)
    expect(cost['time']).to eq(14)
    expect(cost['res']['gold']).to eq(15)
    expect(cost['res']['wood']).to eq(6)
    expect(cost['res']['stone']).to eq(2)
  end
end
