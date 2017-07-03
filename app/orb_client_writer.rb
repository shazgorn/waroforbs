class OrbClientWriter
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  attr_writer :token

  def initialize(websocket, name)
    @name = name
    @websocket = websocket
    @token = nil
    subscribe('send_units_to_user', :send_units)
  end

  def make_result args
    unless args[:user_data]
      error 'No user_data in args'
      return
    end
    res = {}
    # this is our guy
    game = args[:game]
    if args[:user_data].has_key?(@name)
      user_data = args[:user_data][@name]
      if user_data.has_key?(:error)
        res[:error] = user_data[:error]
        return res
      else
        res = user_data
        if user_data[:data_type] == :init_map
          res.merge!(game.init_map(@token))
        end
      end
      res[:units] = game.all_units(@token)
    else
      res = {:units => game.all_units(@token), :data_type => :units}
    end
    res
  end

  ##
  # args => {:game => game, :user_data => {key => data}}
  # writer must check the key and send data to to socket on match
  # data has :op, :log, :token etc

  def send_units topic, args
    info 'send_units'
    unless @token
      error 'No token is set in writer ' + @name
      return
    end
    res = make_result args
    if res
      @websocket << JSON.generate(res)
    end
  rescue Reel::SocketError
    info "#{@name} disconnected"
    terminate
  end
end
