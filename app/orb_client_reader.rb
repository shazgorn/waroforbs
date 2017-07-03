class OrbClientReader
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  def initialize(websocket, writer_name, reader_name, request_layer_name)
    @websocket = websocket
    @writer_name = writer_name
    @name = reader_name
    @request_layer_name = request_layer_name
    @token = nil
    @token_is_set = false
  end

  def read_message_from_socket
    info 'new_message'
    msg = @websocket.read
    info msg
    data = JSON.parse msg
    data['writer_name'] = @writer_name
    @token = data['token']
    unless @token_is_set
      Actor[@writer_name].token = @token
      @token_is_set = true
    end
    Actor[@request_layer_name].parse_user_data(data)
    async.read_message_from_socket
  rescue Reel::SocketError, EOFError
    info "WS client disconnected #{@name}"
    terminate
  end
end
