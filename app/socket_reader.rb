class SocketReader
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  finalizer :my_finalizer

  def initialize(websocket, writer_name, reader_name, facade_name)
    @websocket = websocket
    @writer_name = writer_name
    @name = reader_name
    @facade_name = facade_name
    @token = nil
    @token_is_set = false
  end

  def read_message_from_socket
    info 'Read from socket'
    msg = @websocket.read
    info "Message: #{msg}"
    data = JSON.parse msg
    data['writer_name'] = @writer_name
    if data['op'] == 'close'
      terminate
    end
    @token = data['token']
    unless @token_is_set
      Actor[@writer_name].token = @token
      @token_is_set = true
    end
    Actor[@facade_name].parse_user_data(data)
    async.read_message_from_socket
  rescue IOError
    info 'Socket closed. Terminate reader'
    terminate
  # rescue Reel::SocketError, EOFError
  #   info "WS client disconnected from reader #{@name}"
  #   terminate
  end

  def my_finalizer
    info "Reader #{@name} final"
  end
end
