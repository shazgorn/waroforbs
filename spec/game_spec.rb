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

  it 'is moving' do
    user = User.new('mover')
    x = 1
    y = 1
    unit = HeavyInfantry.new(x, y, user)
    Celluloid::Actor[:game].move_user_hero_by(user, 666, -1, -1)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_unit_not_found', unit_id: 666))
    Celluloid::Actor[:game].move_user_hero_by(user, unit.id, 100, -1)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_wrong_direction'))
    Celluloid::Actor[:game].move_user_hero_by(user, unit.id, -1, -1)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_out_of_map'))
    dx = 1
    dy = 1
    Celluloid::Actor[:game].move_user_hero_by(user, unit.id, dx, dy)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_move', unit_id: unit.id, dx: dx, dy: dy, new_x: x + dx, new_y: y + dy))
    x = x + dx
    y = y + dy
    unit2 = HeavyInfantry.new(3, 3, user)
    Celluloid::Actor[:game].move_user_hero_by(user, unit.id, dx, dy)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_cell_occupied'))
    unit2.die
    Celluloid::Actor[:game].move_user_hero_by(user, unit2.id, dx, dy)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_unit_dead'))
    # can move to 'dead'(unit's) cell
    Celluloid::Actor[:game].move_user_hero_by(user, unit.id, dx, dy)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_move', unit_id: unit.id, dx: dx, dy: dy, new_x: x + dx, new_y: y + dy))
    logs = nil
    HeavyInfantry::BASE_AP.times do
      Celluloid::Actor[:game].move_user_hero_by(user, unit.id, dx, dy)
      logs = LogBox.get_current_by_user(user)
    end
    expect(logs.first.message).to eq(I18n.t('log_entry_not_enough_ap'))
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

  it 'is dismiss' do
    user = User.new('dismisser')
    hi = HeavyInfantry.new(1, 1, user)
    hi_id = hi.id
    Celluloid::Actor[:game].dismiss(user, hi.id)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_unit_dismissed', unit_id: hi_id))
    unit = Unit.get_by_user_id(user, hi_id)
    expect(unit).to be_nil
  end

  it 'is restart' do
    user = User.new('dismisser')
    HeavyInfantry.new(1, 1, user)
    HeavyInfantry.new(2, 2, user)
    HeavyInfantry.new(3, 3, user)
    Celluloid::Actor[:game].restart(user)
    expect(Unit.get_by_user(user).size).to eq(1)
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
end
