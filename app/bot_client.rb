require 'json'
require 'websocket-eventmachine-client'

EM.run do

  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://0.0.0.0:9293')

  DELAY = 1

  USER_NAME = 'bot_client' + ARGV[0]

  f = Fiber.new do |ws|
    ws.send({token: USER_NAME, op: 'init'}.to_json)
    msg = Fiber.yield

    data = JSON.parse(msg)
    units = data["units"]
    units.select!{|key, value| value.has_key?('@user_name') && value['@user_name'] == USER_NAME}
    loop do
      units.each {|k, v|
        if v.has_key?('@user_name') && v['@user_name'] == USER_NAME
          id = v['@id']
          ws.send({token: USER_NAME, op: 'move', unit_id: id, params: {dx: -1, dy: -1}}.to_json)
          Fiber.yield
        end
      }
    end
  end

  ws.onopen do
    puts 'Connected'
    f.resume(ws)
  end

  ws.onmessage do |msg, type|
    puts "Received message: #{msg} #{type}"
    sleep(DELAY)
    f.resume(msg)
  end

  ws.onclose do |code, reason|
    puts "Disconnected with status code: #{code}"
  end

end
