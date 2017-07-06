# coding: utf-8

class OrbWebsocketsServer < Reel::Server::HTTP
  include Celluloid::Internals::Logger
  def initialize(host = "0.0.0.0", port = 9293)
    info 'Starting websocket server'
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
    ClientContainer.new(@websocket_id, socket)
    @websocket_id += 1
  end

  def handle_request(request)
    request.respond :ok, "Hello, world!"
  end
end
