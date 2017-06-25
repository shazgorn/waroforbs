class OrbClientWriter
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  attr_writer :token

  def initialize(websocket, reader_name)
    @socket = websocket
    @reader_name = reader_name
    @map_initialized = false
    @token = nil
    subscribe('send_units_to_user', :send_units)
  end

  def send_units topic, args
    info 'send_units'
    return unless @token
    game = args[:game]
    user_data = args[:user_data]
    res = {
      :units => game.all_units(@token),
      :data_type => @map_initialized ? 'units' : 'init'
    }
    unless @map_initialized
      res.merge!(game.init_map @token)
      @map_initialized = true
    end
    if user_data.has_key?(@token)
      res.merge!(user_data[@token])
    end
    @socket << JSON.generate(res)
  rescue Reel::SocketError
    info "Time client disconnected"
    terminate
  end
end
