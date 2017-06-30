require 'game'

RSpec.describe Game, "testing" do
  let (:game) { Game.new }
  let (:token) { 'test_token' }

  it 'is initializing user' do
    log_entry = game.init_user token
    expect(log_entry.class).to eq(LogEntry)
    expect(log_entry.message).to match(/^New user/)
  end
end
