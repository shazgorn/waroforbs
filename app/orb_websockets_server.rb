# coding: utf-8

require 'webmachine'

OrbWebsocketsServer = Webmachine::Application.new do |app|
  app.configure do |config|
    config.ip      = '0.0.0.0'
    config.port    = 9293
    config.adapter = :Reel
    @websocket_id = 1

    # Optional: handler for incoming websockets
    config.adapter_options[:websocket_handler] = proc do |socket|
      reader = OrbClientReader.new(socket, "writer_#{@websocket_id}")
      writer = OrbClientWriter.new(socket, "reader_#{@websocket_id}")
      Celluloid::Actor["reader_#{@websocket_id}"] = reader
      Celluloid::Actor["writer_#{@websocket_id}"] = writer
      @websocket_id += 1
    end
  end
end
