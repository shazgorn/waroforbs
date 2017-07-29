require 'celluloid/current'
require 'reel'
require 'socket_writer'

class DumbSocket
  def read
    puts 'read'
  end

  def << data
    puts data
  end
end

RSpec.describe OrbClientWriter, "testing" do
  around do |ex|
    Celluloid.boot
    Celluloid::Actor[:game] = Game.new(true)
    ex.run
    Celluloid.shutdown
  end

  let (:writer) { OrbClientWriter.new DumbSocket.new, 'writer_1' }
  let (:game) { Game.new }
  let (:token) { 'test_user' }

  it 'failing without token' do
    res = writer.send_units 'units', {}
    expect(res).to be_nil
  end

  context "with token" do
    before (:example) do
      writer.token = token
    end

    it 'Look, mom, no args!' do
      res = writer.send_units 'send_units_to_user', {}
      expect(res).to be_nil
    end

    it 'handles errors' do
      error_msg = 'I`m an error'
      res = writer.make_result({:game => game, :user_data => {writer.name => {:error => error_msg}} })
      expect(res[:error]).to eq error_msg
    end

    it 'is init_map' do
      game.init_user token
      res = writer.make_result({:game => game, :user_data => {writer.name => {:data_type => :init_map}} })
      expect(res).to_not be_nil
      expect(res[:data_type]).to eq(:init_map)
      expect(res[:units]).to be_a(Hash)
    end
  end
end
