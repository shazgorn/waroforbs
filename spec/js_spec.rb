# coding: utf-8
require 'capybara'
require 'capybara/rspec'
require 'capybara/webkit'

Capybara.javascript_driver = :webkit
Capybara.app_host = 'http://0.0.0.0:9292/'
Capybara.run_server = false


RSpec.configure do |config|
  config.include Capybara::DSL
end

RSpec.describe "building process", :js => true do
  fit "signs me in" do
    visit "/"
    within("#login-form") do
      fill_in 'login', with: 'capybara'
    end
    click_button "Войти"
    expect(page).to have_content 'Выход'
    find('.inventory-item-settlers').click()
    expect(page).to have_content 'Основать'
    click_button 'Основать'
  end
end
