# coding: utf-8
require 'capybara'
require 'capybara/rspec'
require 'capybara/webkit'
require 'i18n'

RSpec.configure do |c|
  Capybara.javascript_driver = :webkit
  Capybara.app_host = 'http://0.0.0.0:9292/'
  Capybara.run_server = false
  c.include Capybara::DSL
  c.before(:example) {
    I18n.load_path = Dir[
      File.join('./app/locales', '*.yml'),
      File.join('./front/config/locales/views', '*.yml')
    ]
    I18n.default_locale = :ru
  }
end

RSpec.describe "Gaming process", :js => true do
  it "is playing" do
    visit "/"
    within("#login-form") do
      fill_in 'login', with: 'capybara' + Time.now.hour.to_s + Time.now.min.to_s + Time.now.sec.to_s
    end
    expect(I18n.t('log_in')).to eq('Войти')
    click_button I18n.t('log_in')
    expect(page).to have_content(I18n.t('Exit'))
    find('.inventory-item-settlers').click()
    expect(page).to have_content(I18n.t('res_settlers_action_label'))
    click_button(I18n.t('res_settlers_action_label'))
    find('#unit-info-list > .unit-info:last-of-type').click()
    click_button('Open') # not a bug for now
    expect(page).to have_content(I18n.t('Barracs'))
    find('#barracs .build-button').click()
  end
end
