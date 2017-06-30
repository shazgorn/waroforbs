class OrbClientReader
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  def initialize(websocket, id)
    @id = id
    @websocket = websocket
    @token = nil
    @token_is_set = false
    subscribe('read_message', :new_message)
  end

  def name
    "reader_{@id}"
  end

  def writer_name
    "writer_{@id}"
  end

  def new_message(topic)
    info 'new_message'
    msg = @websocket.read
    info msg
    data = JSON.parse msg
    data['writer_name'] = writer_name
    @token = data['token']
    unless @token_is_set
      Celluloid::Actor[writer_name].token = @token
      @token_is_set = true
    end
    info 'publish_new_user_data'
    publish 'new_user_data', data
  rescue Reel::SocketError, EOFError
    info "WS client disconnected"
    terminate
  end
end
