# coding: utf-8
require 'capybara'
require 'capybara/rspec'
# require 'capybara/webkit'
require 'i18n'
require 'orb_tick'

module PlayHelper
  def log_in
    visit "/"
    login = 'capybara' + Time.now.hour.to_s + Time.now.min.to_s + Time.now.sec.to_s
    within("#login-form") do
      fill_in 'login', with: login
    end
    expect(I18n.t('log_in')).to eq('Войти')
    click_button I18n.t('log_in')
    expect(page).to have_content(I18n.t('Exit'))
    expect(page).to have_no_content('No position or no unit')
    login
  end

  def settle_town
    find('.inventory-item.settlers').click()
    click_button(I18n.t('res_settlers_action_label'))
  end

  def open_town
    find('#unit-info-list > .unit-info:last-of-type').click()
    find('.own.town.select-target').click()
  end

  def restart
    find('#open-options').click()
    find('#restart').click()
  end
end

RSpec.configure do |c|
  Capybara.javascript_driver = :selenium
  Capybara.app_host = 'http://0.0.0.0:9292/'
  Capybara.run_server = false
  c.include TimeHelper
  c.include PlayHelper
  c.include Capybara::DSL
  c.before(:example) {
    I18n.load_path = Dir[
      File.join('./app/locales', '*.yml'),
      File.join('./front/locales', '*.yml')
    ]
    I18n.default_locale = :ru
  }
end

RSpec.describe "Front tests", :js => true do
  it "is testing user info" do
    login = log_in
    # sleep(1) # wait init_map
    expect(find('#user-info-nickname-value').text).to eq(login)
    expect(find('#user-info-glory-value').text).to eq("#{Config.get('START_GLORY')}/#{Config.get('START_MAX_GLORY')}")
  end

  it "is renaming" do
    log_in
    unit_name = find('#unit-info-list > .unit-info:first-of-type .unit-name-info').text
    # units are named after class name
    expect(unit_name).to eq(I18n.t(Config['unit_class'][Config['START_UNIT_TYPE']]))
    find('#unit-info-list > .unit-info:first-of-type .unit-name-info').double_click
    # selenium does not support double clicks
    if Capybara.javascript_driver == :selenium
      page.execute_script("$('#unit-info-list > .unit-info:first-of-type .unit-name-info').dblclick();")
    end
    expect(page).to have_css('#edit-unit-name')
    expect(find('#edit-unit-name').value).to eq(unit_name)
    find('#unit-info-list > .unit-info:first-of-type .unit-name-info .cancel-button').click()
    expect(find('#unit-info-list > .unit-info:first-of-type .unit-name-info').text).to eq(unit_name)
    expect(page).to have_no_css('#unit-info-list > .unit-info:first-of-type .unit-name-info input')
    find('#unit-info-list > .unit-info:first-of-type .unit-name-info').double_click
    if Capybara.javascript_driver == :selenium
      page.execute_script("$('#unit-info-list > .unit-info:first-of-type .unit-name-info').dblclick();")
    end
    new_unit_name = 'New squad name'
    fill_in 'edit-unit-name', with: new_unit_name
    find('#unit-info-list > .unit-info:first-of-type .unit-name-info .ok-button').click()
    expect(page).to have_no_css('#unit-info-list > .unit-info:first-of-type .unit-name-info input')
    expect(find('#unit-info-list > .unit-info:first-of-type .unit-name-info').text).to eq(new_unit_name)
    find('#unit-info-list > .unit-info:first-of-type .unit-name-info'){|div| expect(div['title']).to eq(new_unit_name)}
    find('.own.swordsman'){|div| expect(div['title']).to eq(new_unit_name)}
  end

  it "is moving" do
    log_in
    old_xy = find('.unit-xy-info').text
    find('#control_7').click
    find('#control_8').click
    find('#control_9').click
    find('#control_6').click
    find('#control_3').click
    find('#control_2').click
    find('#control_1').click
    expect(find('.unit-xy-info').text).not_to eql(old_xy)
  end

  it "is attacking" do
    log_in
    xy = find('#unit-info-list > .active-unit-info .unit-xy-info').text.split
    page.execute_script("App.spawn_dummy_near(#{xy[0]},#{xy[1]});")
    expect(page).to have_css('.attack-target')
    defender = first('.attack-target')
    start_defender_life = defender.find('.life-box').text.to_i
    expect(1..Config.get('MAX_LIFE')).to include(start_defender_life)
    defender.click()
    defender_wounds = find('.casualties-defender .wounds').text.to_i
    defender_kills = find('.casualties-defender .kills').text.to_i
    defender_casualties = defender_wounds + defender_kills
    defender_life = defender.find('.life-box').text.to_i
    expect(start_defender_life - defender_casualties).to eq(defender_life)
    sleep(3) # wait for casualties numbers to disappear
    page.execute_script("App.provoke_dummy_attack();")
    expect(page).to have_css('.casualties-defender')
  end

  it "is restarting", :slow => true do
    log_in
    find('.inventory-item.settlers').click()
    click_button(I18n.t('res_settlers_action_label'))
    find('.unit-info:last-of-type').click()
    find('.own.town.select-target').click()
    find('#build-mode-on').click()
    find('.modal.town .building-card-barracs .build-button').click()
    find('#build-mode-off').click()
    sleep(hm_to_seconds(find('.building-card-barracs .building-time').text))
    find('.modal.town .building-can-upgrade #open-screen-barracs').click()
    restart
    find('.inventory-item.settlers').click()
    click_button(I18n.t('res_settlers_action_label'))
    find('.own.town.select-target').click()
    expect(page).to have_no_content(I18n.t('Hire'))
  end

  it "is building", :slow => true do
    log_in
    find('.inventory-item.settlers').click()
    expect(page).to have_content(I18n.t('res_settlers_action_label'))
    click_button(I18n.t('res_settlers_action_label'))
    find('#unit-info-list > .unit-info:last-of-type').click()
    find('.own.town.select-target').click()
    find('#build-mode-on').click()
    expect(page).to have_content(I18n.t('Barracs'))
    find('.modal.town .building-card-barracs .build-button').click()
    find('#build-mode-off').click()
    sleep(hm_to_seconds(find('.building-card-barracs .building-time').text))
    find('.modal.town .building-can-upgrade #open-screen-barracs').click()
  end

  it "is testing workers", :slow => true do
    log_in
    settle_town
    open_town
    worker = find('#worker-1')
    worker.click()
    worker.assert_matches_selector('#worker-1.worker-selected')
    first('.worker-cell-mountain').click()
    page.assert_selector('.has-worker.worker-cell-mountain')
    page.assert_selector('.town-inventory-inner .inventory-item', count: 5)
    sleep(Config['resource']['stone']['production_time'].to_i + OrbTick::TICK_TIME) # stone production_time + tick_interval
    click_button('control_5')
    page.assert_selector('.town-inventory-inner .inventory-item', count: 5)
  end
end
