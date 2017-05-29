require 'celluloid/current'
require 'celluloid/websocket/client'
require 'json'

class OrbsClient
  include Celluloid
  include Celluloid::Internals::Logger

  def initialize()
    @client = Celluloid::WebSocket::Client.new('ws://0.0.0.0:9293/', current_actor)
    @user = 'orbs_client'
  end

  def on_open
    @client.text JSON.dump(:token => @user, :op => "init")
  end

  def on_message(data)
    message = JSON.parse(data)
  end

  def spawn_green_orb
    @client.text JSON.dump(:token => @user, :op => 'spawn_green_orb')
  end

  def spawn_black_orb
    @client.text JSON.dump(:token => @user, :op => 'spawn_black_orb')
  end
end

client = OrbsClient.new

loop do
  sleep(1)
  client.spawn_green_orb
  sleep(1)
  client.spawn_black_orb
end
