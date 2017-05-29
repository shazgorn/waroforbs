require 'celluloid/current'
require 'celluloid/websocket/client'
require 'json'

class BotClient
  include Celluloid

  @@user_id = 1

  def initialize()
    @client = Celluloid::WebSocket::Client.new('ws://0.0.0.0:9293/', current_actor)
    @user = 'bot_' + @@user_id.to_s
    @@user_id += 1
    @unit_id = nil
  end

  def on_open
    @client.text JSON.dump(:token => @user, :op => "init")
  end

  def on_message(data)
    data = JSON.parse(data)
    units = data["units"]
    units.select!{|key, value| value.has_key?('@user_name') && value['@user_name'] == @user}
    units.each {|k, v|
      if v.has_key?('@user_name') && v['@user_name'] == @user && v['@dead'] == false
        @unit_id = v['@id']
        return
      end
    }
  end

  def move_unit
    if @unit_id
      dx = Random.rand(-1..1)
      dy = Random.rand(-1..1)
      Internals::Logger.info "#{@user}: #{@unit_id} by {#{dx}:#{dy}}"
      if dx || dy
        @client.text JSON.dump(:token => @user, :op => 'move', :unit_id => @unit_id, :params => {:dx => dx, :dy => dy})
      end
    else
      @client.text JSON.dump(:token => @user, :op => 'new_hero')
    end
  end
end

POOL_SIZE = ARGV.fetch(0, 10).to_i

pool = BotClient.pool(size: POOL_SIZE)

loop do
  begin
    sleep 1
    #pool.move_unit
    (0..POOL_SIZE-1).to_a.each {|n| pool.async.move_unit}
  rescue Interrupt
    exit
  end
end

  # def run_black_orb_spawner
  #   begin
  #     if @game.black_orbs_below_limit
  #       orb = @game.spawn_black_orb
  #       speed = Config.get("BLACK_ORB_START_SPEED")
  #       max_speed = Config.get("BLACK_ORB_MAX_SPEED")
  #       logger.info "spawn black orb"
  #       dispatch_units
  #       Thread.new {
  #         begin
  #           while true
  #             res = @game.attack_adj_cells orb
  #             users = {}
  #             if res
  #               if res[:d_data][:dead]
  #                 orb.lvl_up
  #                 speed -= 1 if speed > max_speed
  #               end
  #               logger.debug 'black orb attack'
  #               set_def_data users, res
  #             else
  #               @game.random_move orb
  #             end
  #             dispatch_units(users)
  #             sleep(speed)
  #           end
  #         rescue => e
  #           ex e
  #         end
  #       }
  #     end
  #   rescue => e
  #     ex e
  #   end
  # end

