require 'log_box'

RSpec.describe LogBox, "testing" do
  fit 'testing request get' do
    user = User.new('test_token')
    LogBox.push(:test, 'Test message', user)
    logs = LogBox.get_current_by_user(user)
    expect(logs.count).to eq(1)
    expect(logs.first.message).to eq('Test message')
    logs = LogBox.get_current_by_user(user)
    expect(logs).to be_nil
  end
end
