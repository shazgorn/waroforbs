require 'em-websocket-client'
require 'json'

EM.run do
  conn = EventMachine::WebSocketClient.connect("ws://0.0.0.0:9293/")
  TOKEN = 'orbs_client'

  conn.callback do
    conn.send_msg({token: TOKEN, op: 'init'}.to_json)
    conn.send_msg({token: TOKEN, op: 'new_green_orb'}.to_json)
  end

  conn.errback do |e|
    puts "Got error: #{e}"
  end

  conn.stream do |msg|
    puts "<#{msg}>"
    if msg.data == "done"
      conn.close_connection
    end
  end

  conn.disconnect do
    conn.send_msg({token: TOKEN, op: 'close'})
    puts "gone"
    EM::stop_event_loop
  end


end
