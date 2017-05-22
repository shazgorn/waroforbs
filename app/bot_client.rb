require 'json'
require 'thread'
require 'websocket-eventmachine-client'

EM.run do

  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://0.0.0.0:9293')
  m = Mutex.new

  USER_NAME = 'bot_client' + ARGV[0]
  DELAY = 1

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
        dx = Random.rand(-1..1)
        dy = Random.rand(-1..1)
        puts "#{dx} #{dy}"
        data = JSON.parse(msg)
        units = data["units"]
        units.select!{|key, value| value.has_key?('@user_name') && value['@user_name'] == USER_NAME}
        units.each {|k, v|
          if v.has_key?('@user_name') && v['@user_name'] == USER_NAME
            id = v['@id']
            p id
            ws.send({token: USER_NAME, op: 'move', unit_id: id, params: {dx: dx, dy: dy}}.to_json)
          end
        }
        puts "message has been sent"
        m.unlock
      }
    end
  end

  ws.onclose do |code, reason|
    puts "Disconnected with status code: #{code}"
  end

end
