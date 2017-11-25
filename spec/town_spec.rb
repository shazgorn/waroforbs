require 'game'

RSpec.describe Town, "testing" do
  it 'is setting worker' do
    user = User.new('towner')
    town = Town.new(1, 1, user)
    town.set_worker_to(1, 2, 2, :gold, 1)
  end
end
