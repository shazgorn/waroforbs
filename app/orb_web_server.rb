class OrbWebServer < Reel::Server::HTTP
  include Celluloid::Internals::Logger

  def initialize(host = "0.0.0.0", port = 9293)
    info "Web server starting on #{host}:#{port}"
    super(host, port, &method(:on_connection))
    @id = 1
    p self
  end

  def on_connection(connection)
    while request = connection.request
      if request.websocket?
        info "Received a WebSocket connection"
        connection.detach

        route_websocket request.websocket
        return
      else
        route_request connection, request
      end
    end
  end

  def route_websocket(socket)
    if socket.url == "/"
      reader = OrbClientReader.new(socket, "writer_#{@id}")
      writer = OrbClientWriter.new(socket, "reader_#{@id}")
      Celluloid::Actor["reader_#{@id}"] = reader
      Celluloid::Actor["writer_#{@id}"] = writer
      @id += 1
    else
      info "Received invalid WebSocket request for: #{socket.url}"
      socket.close
    end
  end
end
