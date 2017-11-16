# coding: utf-8
require 'capybara'
require 'capybara/rspec'
require 'capybara/webkit'
require 'i18n'

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
    login
  end

  def restart
    find('#open-options').click()
    find('#restart').click()
  end
end

RSpec.configure do |c|
  Capybara.javascript_driver = :webkit
  Capybara.app_host = 'http://0.0.0.0:9292/'
  Capybara.run_server = false
  #Capybara.raise_javascript_errors = true
  c.include TimeHelper
  c.include PlayHelper
  c.include Capybara::DSL
  c.before(:example) {
    I18n.load_path = Dir[
      File.join('./app/locales', '*.yml'),
      File.join('./front/config/locales/views', '*.yml')
    ]
    I18n.default_locale = :ru
  }
end

Capybara::Webkit.configure do |config|
  config.allow_url("0.0.0.0")
  config.raise_javascript_errors = true
end


RSpec.describe "Front tests", :js => true do
  it "is testing user info" do
    login = log_in
    sleep(1) # wait init_map
    expect(find('#user-info-nickname-info').text).to eq(login)
    expect(find('#user-info-glory-info').text).to eq("#{Config.get('START_GLORY')}/#{Config.get('START_MAX_GLORY')}")
  end

  it "is renaming" do
    log_in
    unit_name = find('#unit-info-list > .unit-info:first-of-type .unit-name-info').text
    expect(unit_name).to eq(I18n.t('Swordsman'))
    find('#unit-info-list > .unit-info:first-of-type .unit-name-info').double_click()
    expect(page).to have_css('#unit-info-list > .unit-info:first-of-type .unit-name-info input')
    expect(find('#edit-unit-name').value).to eq(unit_name)
    find('#unit-info-list > .unit-info:first-of-type .unit-name-info .cancel-button').click()
    expect(find('#unit-info-list > .unit-info:first-of-type .unit-name-info').text).to eq(unit_name)
    expect(page).to have_no_css('#unit-info-list > .unit-info:first-of-type .unit-name-info input')
    find('#unit-info-list > .unit-info:first-of-type .unit-name-info').double_click()
    new_unit_name = 'New squad name'
    fill_in 'edit-unit-name', with: new_unit_name
    find('#unit-info-list > .unit-info:first-of-type .unit-name-info .ok-button').click()
    sleep(1)
    expect(find('#unit-info-list > .unit-info:first-of-type .unit-name-info').text).to eq(new_unit_name)
    find('#unit-info-list > .unit-info:first-of-type .unit-name-info'){|div| expect(div['title']).to eq(new_unit_name)}
    find('.player-hero'){|div| expect(div['title']).to eq(new_unit_name)}
  end

  it "is restarting", :slow => true do
    log_in
    find('.inventory-item-settlers').click()
    click_button(I18n.t('res_settlers_action_label'))
    find('.player-town').click()
    find('.modal.town .building-card-barracs .build-button').click()
    barracs_time_cost = Config.get('barracs')['cost_time']
    sleep(barracs_time_cost)
    find('.modal.town .building-built #open-screen-barracs').click()
    restart
    find('.inventory-item-settlers').click()
    click_button(I18n.t('res_settlers_action_label'))
    find('.player-town').click()
    expect(page).to have_no_content(I18n.t('Hire squad'))
  end

  it "is building", :slow => true do
    log_in
    find('.inventory-item-settlers').click()
    expect(page).to have_content(I18n.t('res_settlers_action_label'))
    click_button(I18n.t('res_settlers_action_label'))
    find('#unit-info-list > .unit-info:last-of-type').click()
    find('.player-town').click()
    expect(page).to have_content(I18n.t('Barracs'))
    find('.modal.town .building-card-barracs .build-button').click()
    barracs_time_cost = Config.get('barracs')['cost_time']
    expect(find('.modal.town .building-in-progress .building-time').text).to eq(seconds_to_hm(barracs_time_cost))
    sleep(barracs_time_cost)
    find('.modal.town .building-built #open-screen-barracs').click()
  end
end
