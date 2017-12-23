require 'game'

RSpec.configure do |c|
  c.before(:example) {
    I18n.load_path = Dir[
      File.join('./app/locales', '*.yml'),
      File.join('./front/locales', '*.yml') # do not remove me
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

  it 'init map' do
    Celluloid::Actor[:game].init_user(token)
    hash = Celluloid::Actor[:game].init_map(token)
    expect(hash).to be_a(Hash)
  end

  context "is moving" do
    before(:example) do
      @user = User.new('mover')
      @x = 5
      @y = 5
      @dx = 1
      @dy = 1
      @unit = Swordsman.new(@x, @y, @user)
    end

    it 'is moving nobody' do
      Celluloid::Actor[:game].move_user_hero_by(@user, 666, -1, -1)
      expect(LogBox.get_current_by_user(@user).first.message).to eq(I18n.t('log_entry_unit_not_found', unit_id: 666))
    end

    it 'is moving in wrong direction' do
      Celluloid::Actor[:game].move_user_hero_by(@user, @unit.id, 100, -1)
      expect(LogBox.get_current_by_user(@user).first.message).to eq(I18n.t('log_entry_wrong_direction'))
    end

    it 'is out of map' do
      unit = Swordsman.new(1, 1, @user)
      Celluloid::Actor[:game].move_user_hero_by(@user, unit.id, -1, -1)
      expect(LogBox.get_current_by_user(@user).first.message).to eq(I18n.t('log_entry_out_of_map'))
    end

    it 'success move' do
      Celluloid::Actor[:game].move_user_hero_by(@user, @unit.id, @dx, @dy)
      expect(LogBox.get_current_by_user(@user).first.message).to eq(I18n.t('log_entry_move', unit_id: @unit.id, dx: @dx, dy: @dy, new_x: @x + @dx, new_y: @y + @dy))
    end

    it 'occupy wallstreet' do
      Swordsman.new(@x + @dx, @y + @dy, @user)
      Celluloid::Actor[:game].move_user_hero_by(@user, @unit.id, @dx, @dy)
      expect(LogBox.get_current_by_user(@user).first.message).to eq(I18n.t('log_entry_cell_occupied'))
    end

    it 'we are the dead' do
      unit2 = Swordsman.new(@x + @dx, @y + @dy, @user)
      unit2.die
      Celluloid::Actor[:game].move_user_hero_by(@user, unit2.id, @dx, @dy)
      expect(LogBox.get_current_by_user(@user).first.message).to eq(I18n.t('log_entry_unit_dead'))
    end

    it 'crush the bones!' do
      Celluloid::Actor[:game].move_user_hero_by(@user, @unit.id, @dx, @dy)
      expect(LogBox.get_current_by_user(@user).first.message).to eq(I18n.t('log_entry_move', unit_id: @unit.id, dx: @dx, dy: @dy, new_x: @x + @dx, new_y: @y + @dy))
    end

    it 'into the town' do
      Town.new(@x + @dx, @y + @dy, @user)
      Celluloid::Actor[:game].move_user_hero_by(@user, @unit.id, @dx, @dy)
      expect(LogBox.get_current_by_user(@user).first.message).to eq(I18n.t('log_entry_move', unit_id: @unit.id, dx: @dx, dy: @dy, new_x: @x + @dx, new_y: @y + @dy))
    end

    it 'no fuel' do
      dx = @dx
      dy = @dy
      logs = nil
      (Config[@unit.type.to_s]['ap'].to_i + 20).times do
        Celluloid::Actor[:game].move_user_hero_by(@user, @unit.id, dx, dy)
        logs = LogBox.get_current_by_user(@user)
        dx *= -1
        dy *= -1
      end
      expect(logs.first.message).to eq(I18n.t('log_entry_not_enough_ap'))
    end
  end

  it 'attack' do
    a_user = User.new('attacker')
    a = Swordsman.new(1, 1, a_user)
    d_user = User.new('defender')
    d = Swordsman.new(2, 2, d_user)
    Celluloid::Actor[:game].attack(a, d)
  end

  it 'user attack' do
    a_user = User.new('attacker')
    a = Swordsman.new(1, 1, a_user)
    d_user = User.new('defender')
    d = Swordsman.new(2, 2, d_user)
    res = Celluloid::Actor[:game].attack_by_user(a_user, 0, d.id)
    expect(LogBox.get_current_by_user(a_user).first.message).to eq(I18n.t('log_entry_wrong_attacker_id'))
    res = Celluloid::Actor[:game].attack_by_user(a_user, a.id, 0)
    expect(LogBox.get_current_by_user(a_user).first.message).to eq(I18n.t('log_entry_defender_not_found'))
    res = Celluloid::Actor[:game].attack_by_user(a_user, a.id, d.id)
    at = Swordsman.new(5, 5, a_user)
    d_town = Town.new(4, 4, d_user)
    10.times do
      res = Celluloid::Actor[:game].attack_by_user(a_user, at.id, d_town.id)
    end
    LogBox.get_current_by_user(a_user)
    Celluloid::Actor[:game].move_user_hero_by(a_user, at.id, -1, -1)
    LogBox.get_current_by_user(a_user)
  end

  it 'is disband' do
    user = User.new('disbander')
    hi = Swordsman.new(1, 1, user)
    hi_id = hi.id
    Celluloid::Actor[:game].disband(user, hi.id)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_unit_disbanded', unit_id: hi_id))
    unit = Unit.get_by_user_id(user, hi_id)
    expect(unit).to be_nil
  end

  it 'is building' do
    user = User.new('builder')
    Town.new(1, 1, user)
    b_name = 'barracs'
    Celluloid::Actor[:game].build(user, b_name.to_sym)
    LogBox.get_current_by_user(user) # clean building started
    Celluloid::Actor[:game].build(user, b_name.to_sym)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_building_already_in_progress'))
    Celluloid::Actor[:game].build(user, :tavern)
  end

  it 'is hiring units', :slow => true do
    user = User.new('hirer')
    town = Town.new(1, 1, user)
    b_name = 'barracs'
    Celluloid::Actor[:game].hire_unit(user, Config['buildings'][b_name]['units'].first)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_building_not_build', building: I18n.t(b_name.capitalize)))
    town.build(b_name.to_sym)
    sleep(Config['buildings'][b_name]['cost'][1]['time'])
    expect(Config['buildings'][b_name]['units'].include?('swordsman')).to be true
    Celluloid::Actor[:game].hire_unit(user, Config['buildings'][b_name]['units'].first)
    expect(Unit.get_by_user(user).length).to eq(2)
    LogBox.get_current_by_user(user)
    wrong_squad_type = 'wrong_squad_type'
    Celluloid::Actor[:game].hire_unit(user, wrong_squad_type)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_unknown_unit', unit_type: wrong_squad_type))
  end

  it 'hire hero_swordsman', :slow => true do
    user = User.new('hirer')
    town = Town.new(1, 1, user)
    Celluloid::Actor[:game].hire_unit(user, 'hero_swordsman')
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_building_not_build', building: I18n.t('Tavern')))
    expect(Unit.get_by_user(user).length).to eq(1)
    town.build(:tavern)
    sleep(Config['buildings']['tavern']['cost'][1]['time'])
    Celluloid::Actor[:game].hire_unit(user, 'hero_swordsman')
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_building_not_build', building: I18n.t('Barracs')))
    expect(Unit.get_by_user(user).length).to eq(1)
    town.build(:barracs)
    sleep(Config['buildings']['barracs']['cost'][1]['time'])
    Celluloid::Actor[:game].hire_unit(user, 'hero_swordsman')
    expect(Unit.get_by_user(user).length).to eq(2)
    expect(LogBox.get_current_by_user(user).first.message). to eq(I18n.t('log_entry_new_unit', name: I18n.t('Hero swordsman')))
  end

  it 'is renaming unit' do
    user = User.new('disbander')
    hi = Swordsman.new(1, 1, user)
    old_name = hi.name
    new_name = 'New name'
    Celluloid::Actor[:game].rename_unit(user, hi.id, new_name)
    expect(LogBox.get_current_by_user(user).first.message).to eq(I18n.t('log_entry_unit_renamed', old_name: old_name, new_name: new_name))
  end

  it 'is restart' do
    user = User.new('restarter')
    Swordsman.new(1, 1, user)
    Swordsman.new(2, 2, user)
    Swordsman.new(3, 3, user)
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

  it 'is setting worker' do
    user = User.new('worker')
    town = Town.new(1, 1, user)
    Celluloid::Actor[:game].set_worker_to_xy(user, town.id, 1, 2, 2)
  end

  it 'testing empty adj cell xy' do
    xy = Celluloid::Actor[:game].empty_adj_cell_xy(5, 5)
    expect(xy[:x]).to eq(4)
    expect(xy[:y]).to eq(4)
  end

  it 'testing empty adj cell near unit' do
    user = User.new('tester')
    unit = Swordsman.new(5, 5, user)
    xy = Celluloid::Actor[:game].empty_adj_cell(unit)
    expect(xy[:x]).to eq(4)
    expect(xy[:y]).to eq(4)
  end

  it 'testing dummy' do
    x = 3
    y = 3
    Celluloid::Actor[:game].spawn_dummy_near(x, y)
    unit = Unit.get_by_user(User.new(Config['DUMMY_LOGIN'])).first
    expect(unit.x).to eq(x - 1)
    expect(unit.x).to eq(y - 1)
    expect(unit.user.login).to eq(Config['DUMMY_LOGIN'])
  end

  it 'provoke dummy to attack' do
    user = User.new('defender')
    x = 5
    y = 5
    Swordsman.new(x, y, user)
    Celluloid::Actor[:game].spawn_dummy_near(x + 1, y + 1)
    Celluloid::Actor[:game].provoke_dummy_attack()
    expect(LogBox.get_current_by_user(user).first.type).to eq(:defence)
  end

  context "inventory" do
    before(:example) do
      @user = User.new('giver')
      @x = 1
      @y = 1
      @swordsman = @from = Swordsman.new(@x, @y, @user)
      @from.inventory[:gold] = Config['start_res']['gold'].to_i
      @town = @to = Town.new(@x + 1, @y + 1, @user)
    end

    it 'taking' do
      taken_q = @from.take_res(:gold, Config['start_res']['gold'].to_i)
      expect(taken_q).to eq(Config['start_res']['gold'].to_i)
      expect(@from.inventory[:gold]).to eq(0)
    end

    it 'taking more' do
      taken_q = @from.take_res(:gold, Config['start_res']['gold'].to_i + 1)
      expect(taken_q).to eq(Config['start_res']['gold'].to_i)
      expect(@from.inventory[:gold]).to eq(0)
    end

    it 'givinig res' do
      to_gold = @to.inventory[:gold]
      Celluloid::Actor[:game].give(@user, @from.id, @to.id, {'gold' => Config['start_res']['gold'].to_s})
      expect(@from.inventory[:gold]).to eq(0)
      expect(@to.inventory[:gold]).to eq(to_gold + Config['start_res']['gold'].to_i)
    end

    it 'taking res' do
      from_gold = @swordsman.inventory[:gold]
      to_gold = @town.inventory[:gold]
      Celluloid::Actor[:game].take(@user, @town.id, @swordsman.id, {'gold' => Config['start_res']['gold'].to_s})
      expect(@swordsman.inventory[:gold]).to eq(0)
      expect(@town.inventory[:gold]).to eq(to_gold + Config['start_res']['gold'].to_i)
    end
  end
end
