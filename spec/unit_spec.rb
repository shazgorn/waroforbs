require 'game'

RSpec.describe Unit, "testing" do
  around do |ex|
    Celluloid.boot
    User.drop_all
    Unit.drop_all
    Celluloid::Actor[:game] = Game.new
    Celluloid::Actor[:map] = Map.new
    ex.run
    Celluloid.shutdown
  end

  let (:user) { User.new('user') }
  let (:enemy) { User.new('enemy') }

  it 'it deleting units by user' do
    Swordsman.new(1, 1, user)
    Swordsman.new(2, 1, user)
    Swordsman.new(3, 1, user)
    Swordsman.new(4, 1, user)
    Swordsman.new(5, 1, user)
    expect(Unit.get_by_user(user).size).to eq(5)
    Unit.delete_by_user(user)
    expect(Unit.get_by_user(user).size).to eq(0)
  end

  it 'dead unit' do
    x = 5
    y = 5
    hi = Swordsman.new(x, y, user)
    hi.die
    expect(hi.x).to eq(x)
    expect(hi.y).to eq(y)
    expect(hi.dead?).to be true
  end

  it 'dead town' do
    x = 6
    y = 6
    town = Town.new(x, y, user)
    town.die
    expect(town.x).to eq(x)
    expect(town.y).to eq(y)
    expect(town.dead?).to be true
  end

  it 'is killing me and wound SingleEntity' do
    hi = Swordsman.new(2, 2, user)
    hi.kill
    expect(hi.life).to eq(Config.get(:max_life) - 1)
    expect(hi.wounds).to eq(0)
    town = Town.new(3, 3, user)
    town.kill
    expect(town.life).to eq(Config.get(:max_life) - 1)
    expect(town.wounds).to eq(1)
  end

  it 'is destroying building', :slow => true do
    town = Town.new(5, 5, user)
    town.build :barracs
    sleep(Config[:buildings][:barracs][:cost][1][:time].to_i + 2)
    town.kill
  end

  it 'is renaming unit' do
    h = Swordsman.new(5, 5, user)
    h.name = 'new name'
  end

  it 'is enterable' do
    unit = Swordsman.new(5, 5, user)
    town = Town.new(6, 6, user)
    expect(town.enterable_for(unit)).to be true
  end

  it 'all in' do
    Swordsman.new(5, 5, user)
    expect(Unit.all.size).to eq(1)
    ElfSwordsman.new(6, 6, user)
    expect(Unit.all.size).to eq(2)
  end

  describe 'spotting stuff' do
    it 'spotted' do
      unit = Swordsman.new(5, 5, user)
      e_unit = Swordsman.new(7, 7, enemy)
      expect(unit.spotted? e_unit).to be true
    end

    it 'dead have no eyes' do
      unit = Swordsman.new(5, 5, user)
      e_unit = Swordsman.new(7, 7, enemy)
      unit.die
      expect { unit.spotted? e_unit}.to raise_error(DeadHaveNoEyes)
    end

    it 'I see dead people' do
      unit = Swordsman.new(5, 5, user)
      e_unit = Swordsman.new(7, 7, enemy)
      e_unit.die
      expect(unit.spotted? e_unit).to be true
    end
  end
end
