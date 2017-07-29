class ClientContainer
  include Celluloid

  trap_exit :closed

  def initialize(websocket_id, socket)
    @websocket_id = websocket_id
    @socket = socket
    @writer_name = writer_name(@websocket_id)
    @reader_name = reader_name(@websocket_id)
    @facade_name = facade_name(@websocket_id)
    writer = OrbClientWriter.new(socket, @writer_name)
    reader = OrbClientReader.new(socket, @writer_name, @reader_name, @facade_name)
    link reader
    # @fsupervisor = Facade.supervise({as: facade_name})
    Celluloid::Actor[@facade_name] = Facade.new
    Celluloid::Actor[@reader_name] = reader
    Celluloid::Actor[@writer_name] = writer
    reader.async.read_message_from_socket
  end

  def closed(actor, reason)
    Celluloid::Actor[@facade_name].terminate
    Celluloid::Actor[@writer_name].terminate
    # p actor
    # Do not kill the whole group, use separate config or make it real container?
    # @fsupervisor.remove(Actor[facade_name])
    # p @fsupervisor
    # @socket.close
  end

  def writer_name(id)
    "writer_#{id}"
  end

  def reader_name(id)
    "reader_#{id}"
  end

  def facade_name(id)
    "facade_#{id}"
  end
end
