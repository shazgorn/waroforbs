require 'json'
require 'websocket-eventmachine-client'

EM.run do

  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://0.0.0.0:9293')

  orb = 0

  MAX_ORBS = 3
  DELAY = 10

  f = Fiber.new do |ws, message|
    puts message
    ws.send({token: 'orbs_client', op: 'init'}.to_json)
    Fiber.yield
    loop do
      ws.send({token: 'orbs_client', op: 'new_green_orb'}.to_json)
      Fiber.yield
    end
  end

  ws.onopen do
    puts 'Connected'
    f.resume(ws, '')
  end

  ws.onmessage do |msg, type|
    puts "Received message: #{msg} #{type}"
    if orb < MAX_ORBS
      sleep(DELAY)
      f.resume(ws, msg)
      orb += 1
    end
  end

  ws.onclose do |code, reason|
    puts "Disconnected with status code: #{code}"
  end

end
