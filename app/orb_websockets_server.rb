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

  def writer_name id
    "writer_#{id}"
  end

  def reader_name id
    "reader_#{id}"
  end

  def request_name id
    "request_#{id}"
  end

  def handle_websocket(socket)
    writer_name = writer_name(@websocket_id)
    reader_name = reader_name(@websocket_id)
    request_name = request_name(@websocket_id)
    writer = OrbClientWriter.new(socket, writer_name)
    reader = OrbClientReader.new(socket, writer_name, reader_name, request_name)
    supervisor = RequestLayer.supervise({as: request_name})
    Celluloid::Actor[reader_name] = reader
    Celluloid::Actor[writer_name] = writer
    reader.read_message_from_socket
    @websocket_id += 1
  end

  def handle_request(request)
    request.respond :ok, "Hello, world!"
  end
end
