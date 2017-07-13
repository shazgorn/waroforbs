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

  it 'attack' do
    attacker = Celluloid::Actor[:game].init_user 'attacker'
    defender = Celluloid::Actor[:game].init_user 'attacker'
  end
end
