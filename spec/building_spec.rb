require 'game'

RSpec.describe Building, "#testing" do
  it 'is testing barracs' do
    Barracs.new
    Tavern.new
  end

  it 'building', :slow => true do
    b = Tavern.new
    level = 1
    b.build
    sleep(Config['buildings'][b.name]['cost'][level]['time'] + 1)
    b.check_build
    expect(b.status).to eq(Building::STATE_CAN_UPGRADE)
    expect(b.level).to eq(level)
    level = 2
    b.build
    sleep(Config['buildings'][b.name]['cost'][level]['time'] + 1)
    b.check_build
    expect(b.status).to eq(Building::STATE_COMPLETE)
    expect(b.level).to eq(level)
    expect { b.build }.to raise_error(MaxBuildingLevelReached)
  end
end
