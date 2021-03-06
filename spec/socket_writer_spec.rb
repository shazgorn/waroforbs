require 'celluloid/current'
require 'reel'
require 'socket_writer'

class DumbSocket
  def read
    puts 'DumbSocket::read'
  end

  def << data
    puts "DumbSocket data: #{data}"
  end
end

RSpec.describe SocketWriter, "testing" do
  around do |ex|
    Celluloid.boot
    Token.drop_all
    User.drop_all
    Unit.drop_all
    Celluloid::Actor[:turn_counter] = TurnCounter.new
    Celluloid::Actor[:map] = Map.new
    Celluloid::Actor[:game] = Game.new
    ex.run
    Celluloid.shutdown
  end

  let (:writer_name) { 'writer_1' }
  let (:writer) { SocketWriter.new(DumbSocket.new, writer_name) }
  let (:token) { 'test_user' }

  it 'failing without token' do
    res = writer.send_units 'units', {}
    expect(res).to be_nil
  end

  context "with token" do
    before (:example) do
      writer.token = token
      Celluloid::Actor[:game].init_user token
    end

    it 'Look, mom, no args!' do
      res = writer.send_units 'send_units_to_user', {}
      expect(res).to_not be_nil
    end

    it 'handles errors' do
      error_msg = 'I`m an error'
      res = writer.make_result({:user_data => {writer_name => {:error => error_msg}} })
      expect(res[:error]).to eq(error_msg)
    end

    it 'is init_map' do
      Celluloid::Actor[:game].init_user token
      res = writer.make_result({:user_data => {writer_name => {:data_type => :init_map}} })
      expect(res).to_not be_nil
      expect(res[:data_type]).to eq(:init_map)
      expect(res[:units]).to be_a(Hash)
      expect(res[:actions]).to be_a(Hash)
    end
  end
end
