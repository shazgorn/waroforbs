require 'game'

RSpec.describe Unit, "testing" do
  it 'it deleting units by user' do
    user = User.new('deleter')
    Swordsman.new(1, 1, user)
    Swordsman.new(2, 1, user)
    Swordsman.new(3, 1, user)
    Swordsman.new(4, 1, user)
    Swordsman.new(5, 1, user)
    expect(Unit.get_by_user(user).size).to eq(5)
    Unit.delete_by_user(user)
    expect(Unit.get_by_user(user).size).to eq(0)
  end

  it 'is empty cell' do
    user = User.new('test')
    hi = Swordsman.new(5, 5, user)
    hi.die
    expect(hi.x).to be_nil
    expect(hi.y).to be_nil
    expect(hi.dead?).to be true
    town = Town.new(6, 6, user)
    town.die
    expect(town.x).to be_nil
    expect(town.y).to be_nil
    expect(town.dead?).to be true
  end

  it 'is killing me and wound SingleEntity' do
    user = User.new('killer')
    hi = Swordsman.new(2, 2, user)
    hi.kill
    expect(hi.life).to eq(Config.get('MAX_LIFE') - 1)
    expect(hi.wounds).to eq(0)
    town = Town.new(3, 3, user)
    town.kill
    expect(town.life).to eq(Config.get('MAX_LIFE') - 1)
    expect(town.wounds).to eq(1)
  end

  it 'is destroying building', :slow => true do
    user = User.new('destroyer')
    town = Town.new(5, 5, user)
    town.build :barracs
    sleep(Config.get('barracs')['cost_time'] + 2)
    town.kill
  end

  it 'is renaming unit' do
    user = User.new('renamer')
    h = Swordsman.new(5, 5, user)
    h.name = 'new name'
  end

  it 'is enterable' do
    user = User.new('renamer')
    unit = Swordsman.new(5, 5, user)
    town = Town.new(6, 6, user)
    expect(town.enterable_for(unit)).to be true
  end
end
