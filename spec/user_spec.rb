require 'game'

RSpec.describe User, "testing" do
  it 'is multi-user software' do
    user1 = User.new('test')
    user2 = User.new('test')
    expect(user1).to eq(user2)
  end
end
