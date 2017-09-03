require 'game'

RSpec.describe Game, "testing" do
  around do |ex|
    Celluloid.boot
    Token.drop
    Celluloid::Actor[:game] = Game.new(true)
    ex.run
    Celluloid.shutdown
  end

  let (:token) { 'test_game_token' }

  it 'getting no user by token' do
    user = Celluloid::Actor[:game].get_user_by_token(token)
    expect(user).to be_nil
  end

  it 'is initializing user' do
    user = Celluloid::Actor[:game].init_user(token)
    expect(user.class).to eq(User)
    expect(User.all.size).to eq(1)
    user = Celluloid::Actor[:game].init_user(token)
    expect(user.class).to eq(User)
    expect(User.all.size).to eq(1)
    units = Unit.get_by_user(user)
    expect(units.size).to eq(1)
    expect(units.first.inventory[:settlers]).to eq(1)
  end

  it 'attack' do
    a_user = User.new('attacker')
    a = HeavyInfantry.new(1, 1, a_user)
    d_user = User.new('defender')
    d = HeavyInfantry.new(2, 2, d_user)
    Celluloid::Actor[:game].attack(a, d)
  end

  it 'user attack' do
    a_user = User.new('attacker')
    a = HeavyInfantry.new(1, 1, a_user)
    d_user = User.new('defender')
    d = HeavyInfantry.new(2, 2, d_user)
    res = Celluloid::Actor[:game].attack_by_user(a_user, 0, d.id)
    expect(res[:error]).to eq('Wrong attacker id')
    res = Celluloid::Actor[:game].attack_by_user(a_user, a.id, 0)
    expect(res[:error]).to eq('Defender not found')
    res = Celluloid::Actor[:game].attack_by_user(a_user, a.id, d.id)
    expect(res[:d_dmg][:wounds]).to eq(3)
    expect(res[:a_dmg][:wounds]).to eq(2)
  end
end
