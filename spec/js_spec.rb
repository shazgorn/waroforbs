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

RSpec.describe "building process", :js => true do
  fit "signs me in" do
    visit "/"
    within("#login-form") do
      fill_in 'login', with: 'capybara'
    end
    expect(I18n.t('log_in')).to eq('Войти')
    click_button I18n.t('log_in')
    expect(page).to have_content(I18n.t('Exit'))
    find('.inventory-item-settlers').click()
    expect(page).to have_content(I18n.t('res_settlers_action_label'))
    click_button(I18n.t('res_settlers_action_label'))
  end
end