class SocketWriter
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  finalizer :my_finalizer

  attr_writer :token

  def initialize(websocket, name)
    @name = name
    @websocket = websocket
    @token = nil
    subscribe('send_units_to_user', :send_units)
  end

  def make_result(args)
    unless args[:user_data]
      error 'No user_data in args'
      return
    end
    res = {}
    # this is our guy. Prepare data for owner of this socket
    if args[:user_data].has_key?(@name)
      # user specific data
      user_data = args[:user_data][@name]
      if user_data[:error]
        res[:error] = user_data[:error]
        return res
      else
        res = user_data
        # user should be inited at this point
        user = Actor[:game].get_user_by_token(@token)
        # why not in facade, not in Game ?
        if user_data[:data_type] == :init_map
          res.merge!(Actor[:game].init_map(@token))
        end
        # remove duplication of facade.parse_data and following code
        res[:logs] = Actor[:game].get_current_logs_by_user(user)
        res[:user_glory] = user.glory
        res[:user_max_glory] = user.max_glory
        res[:turn] = Actor[:turn_counter].turns
      end
      res[:units] = Actor[:game].all_units_for_user(user)
    else
      # for everyone else
      other_user = Actor[:game].get_user_by_token(@token)
      res = {
        :units => Actor[:game].all_units_for_user(other_user),
        :data_type => :units,
        :logs => Actor[:game].get_current_logs_by_user(other_user),
        # attack info
      }
    end
    res
  end

  ##
  # args => {:user_data => {key => data}}
  # writer must check the key and send data to to socket on match
  # data has :op, :log, :token etc

  def send_units(topic, args)
    unless @token
      error 'No token is set in writer ' + @name
      return
    end
    res = make_result(args)
    if res
      @websocket << JSON.generate(res)
    end
  # rescue Reel::SocketError
  #   info "Ws client disconnected from #{@name} "
  #   terminate
  end

  def my_finalizer
    info "Writer #{@name} final"
    @websocket << JSON.generate({:data_type => :close})
  end
end
