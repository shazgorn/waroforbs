require 'json'
require 'websocket-eventmachine-client'

EM.run do

  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://0.0.0.0:9293')
  m = Mutex.new

  USER_NAME = 'orbs_client'
  MAX_ORBS = 3
  DELAY = 10

  ws.onopen do
    puts 'Connected'
    ws.send({token: USER_NAME, op: 'init'}.to_json)
  end

  ws.onmessage do |msg, type|
    # puts "Received message: #{msg} #{type}"
    unless m.locked?
      Thread.new {
        puts "Thread start"
        m.lock
        sleep(DELAY)
        ws.send({token: USER_NAME, op: 'new_green_orb'}.to_json)
        puts "message has been sent"
        ws.send({token: USER_NAME, op: 'new_black_orb'}.to_json)
        puts "message has been sent"
        m.unlock
      }
    end
  end

  ws.onclose do |code, reason|
    puts "Disconnected with status code: #{code}"
  end

end
