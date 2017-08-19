class ClientContainer
  include Celluloid
  include Celluloid::Internals::Logger

  trap_exit :ws_disconnected

  def initialize(websocket_id, socket)
    @websocket_id = websocket_id
    @socket = socket
    @writer_name = writer_name(@websocket_id)
    @reader_name = reader_name(@websocket_id)
    @facade_name = facade_name(@websocket_id)
    writer = SocketWriter.new(socket, @writer_name)
    reader = SocketReader.new(socket, @writer_name, @reader_name, @facade_name)
    facade = Facade.new
    link reader
    link writer
    link facade
    # @fsupervisor = Facade.supervise({as: facade_name})
    Celluloid::Actor[@facade_name] = facade
    Celluloid::Actor[@reader_name] = reader
    Celluloid::Actor[@writer_name] = writer
    reader.async.read_message_from_socket
  end

  def ws_disconnected(actor, reason)
    p actor
    info "#{actor.inspect}  died, reason: #{reason.class}"
    begin
      info "terminate #{@reader_name}"
      Celluloid::Actor[@reader_name].terminate
    rescue Celluloid::DeadActorError
      warn "#{@reader_name} already dead"
    end
    begin
      info "terminate #{@writer_name}"
      Celluloid::Actor[@writer_name].terminate
    rescue Celluloid::DeadActorError
      warn "#{@writer_name} already dead"
    end
    begin
      info "terminate #{@facade_name}"
      Celluloid::Actor[@facade_name].terminate
    rescue Celluloid::DeadActorError
      warn "#{@facade_name} already dead"
    end
    info 'terminate container'
    terminate
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
