require 'game'

RSpec.describe Unit, "testing" do
  it 'it deleting units by user' do
    user = User.new('deleter')
    HeavyInfantry.new(1, 1, user)
    HeavyInfantry.new(2, 1, user)
    HeavyInfantry.new(3, 1, user)
    HeavyInfantry.new(4, 1, user)
    HeavyInfantry.new(5, 1, user)
    expect(Unit.get_by_user(user).size).to eq(5)
    Unit.delete_by_user(user)
    expect(Unit.get_by_user(user).size).to eq(0)
  end
end
