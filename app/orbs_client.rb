require 'json'
require 'websocket-eventmachine-client'

EM.run do

  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://0.0.0.0:9293')

  orb = 0

  ws.onopen do
    puts 'Connected'
    ws.send({token: 'orbs_client', op: 'init'}.to_json)
  end

  ws.onmessage do |msg, type|
    puts "Received message: #{msg}"
    if orb < 10
      ws.send({token: 'orbs_client', op: 'new_green_orb'}.to_json)
      orb += 1
    end
  end

  ws.onclose do |code, reason|
    puts "Disconnected with status code: #{code}"
  end

end
