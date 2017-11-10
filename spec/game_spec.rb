require 'game'

RSpec.configure do |c|
  c.before(:example) {
    I18n.load_path = Dir[
      File.join('./app/locales', '*.yml'),
      File.join('./front/config/locales/views', '*.yml')
    ]
    I18n.default_locale = :ru
  }
end

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

  it 'settling town' do
    user = Celluloid::Actor[:game].init_user(token)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_new_user', user: token))
    unit = Unit.get_by_user(user).first
    Celluloid::Actor[:game].settle_town(user, unit.id)
    town = Town.get_by_user(user)
    expect(town.user_id).to eq(user.id)
    expect(town.x).to eq(unit.x)
    expect(town.y).to eq(unit.y)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_settle_town'))
    expect(unit.inventory[:settlers]).to eq(0)
    Celluloid::Actor[:game].settle_town(user, unit.id)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_already_have_town'))
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
    expect(LogBox.get_current_by_user(a_user).first.message).to eq(I18n.t('log_entry_wrong_attacker_id'))
    res = Celluloid::Actor[:game].attack_by_user(a_user, a.id, 0)
    expect(LogBox.get_current_by_user(a_user).first.message).to eq(I18n.t('log_entry_defender_not_found'))
    res = Celluloid::Actor[:game].attack_by_user(a_user, a.id, d.id)
    expect(res[:d_dmg][:wounds]).to eq(3)
    expect(res[:a_dmg][:wounds]).to eq(2)
  end
end
