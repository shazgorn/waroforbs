require 'game'

RSpec.describe Building, "#testing" do
  it 'is testing barracs' do
    Barracs.new
    Tavern.new
  end

  it 'building', :slow => true do
    b = Barracs.new
    level = 0
    b.build
    sleep(Config['barracs']['cost_levels'][level + 1]['time'] + 1)
    b.check_build
    expect(b.status).to eq(Building::STATE_CAN_UPGRADE)
    expect(b.level).to eq(level + 1)
    level += 1
    b.build
    sleep(Config['barracs']['cost_levels'][level + 1]['time'] + 1)
    b.check_build
    expect(b.status).to eq(Building::STATE_COMPLETE)
    expect(b.level).to eq(level + 1)
    expect { b.build }.to raise_error(MaxBuildingLevelReached)
  end
end
