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
    writer = OrbClientWriter.new(socket, @websocket_id)
    reader = OrbClientReader.new(socket, @websocket_id)
    Celluloid::Actor[reader.name] = reader
    Celluloid::Actor[writer.name] = writer
    reader.read_message_from_socket
    # Celluloid::Supervision::Container.supervise({
    #                                               as: 'my_game',
    #                                               type: Game,
    #                                               args: [{id: @websocket_id}]
    #                                             })
    @websocket_id += 1
  end

  def handle_request(request)
    request.respond :ok, "Hello, world!"
  end
end
