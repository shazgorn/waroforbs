require "celluloid/current"

require 'orb_game_server'

RSpec.describe OrbGameServer, "#parse_data" do
  around do |ex|
    Celluloid.boot
    ex.run
    Celluloid.shutdown
  end

  let(:server) { OrbGameServer.new }
  let(:writer_name) { 'test' }

  it "sends message without writer name" do
    user_data = server.parse_data 'test'
    expect(user_data).to be_nil
  end

  it "sends message without token" do
    user_data = server.parse_data({'writer_name' => writer_name})
    expect(user_data[writer_name][:error]).to eq('No token')
  end

  it "gets no op" do
    user_data = server.parse_data({'writer_name' => writer_name, 'token' => 'test_token'})
    expect(user_data[writer_name][:error]).to eq('No op')
  end

  it "tests init routine" do
    user_data = server.parse_data({
                                    'writer_name' => writer_name,
                                    'token' => 'test_token',
                                    'op' => 'init_map'
                                  })
    expect(user_data[writer_name][:error]).to be_nil
    expect(user_data[writer_name][:data_type]).to eq(:init_map)
  end
end
