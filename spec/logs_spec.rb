require 'log_box'

RSpec.configure do |c|
  I18n.load_path = Dir[File.join('./app/locales', '*.yml')]
  I18n.default_locale = :ru
end

RSpec.describe LogBox, "#testing" do
  around do |ex|
    Celluloid.boot
    Celluloid::Actor[:game] = Game.new(true)
    ex.run
    Celluloid.shutdown
  end

  it 'testing request get' do
    user = User.new('logs_test_token')
    LogBox.push(:test, 'Test message', user)
    logs = LogBox.get_current_by_user(user)
    expect(logs.count).to eq(1)
    expect(logs.first.message).to eq('Test message')
    logs = LogBox.get_current_by_user(user)
    expect(logs).to be_nil
  end
end
