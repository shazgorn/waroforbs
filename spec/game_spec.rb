require 'game'

RSpec.describe Game, "testing" do
  around do |ex|
    Celluloid.boot
    Celluloid::Actor[:game] = Game.new
    ex.run
    Celluloid.shutdown
  end

  let (:token) { 'test_token' }

  it 'getting no user by token' do
    user = Celluloid::Actor[:game].get_user_by_token token
    expect(user).to be_nil
  end

  it 'is initializing user' do
    user = Celluloid::Actor[:game].init_user(token)
    expect(user.class).to eq(User)
    expect(User.all.size).to eq(1)
    user = Celluloid::Actor[:game].init_user(token)
    expect(user.class).to eq(User)
    expect(User.all.size).to eq(1)
  end

  fit 'attack' do
    a_user = User.new('attacker')
    a = HeavyInfantry.new(1, 1, a_user)
    d_user = User.new('defender')
    d = HeavyInfantry.new(2, 2, d_user)
  end
end
