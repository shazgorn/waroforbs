# coding: utf-8

class OrbWebsocketsServer < Reel::Server::HTTP
  def initialize(host = "0.0.0.0", port = 9293)
    @websocket_id = 1
    super(host, port, &method(:on_connection))
  end

  def on_connection(connection)
    connection.each_request do |request|
      if request.websocket?
        handle_websocket(request.websocket)
      else
        handle_request(request)
      end
    end
  end

  def handle_websocket(socket)
    reader = OrbClientReader.new(socket, @websocket_id)
    writer = OrbClientWriter.new(socket, @websocket_id)
    Celluloid::Actor[reader.name] = reader
    Celluloid::Actor[writer.name] = writer
    @websocket_id += 1
  end

  def handle_request(request)
    request.respond :ok, "Hello, world!"
  end
end
