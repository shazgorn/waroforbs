require 'celluloid/current'
require 'celluloid/websocket/client'
require 'json'

class OrbsClient
  include Celluloid
  include Celluloid::Internals::Logger

  def initialize()
    info 'initialize client'
    @client = Celluloid::WebSocket::Client.new('ws://0.0.0.0:9293/', current_actor)
    @user = 'orbs_client'
  end

  def on_open
    @client.text JSON.dump({:token => @user, :op => "init_map"})
  end

  def on_message(data)
    message = JSON.parse(data)
  end

  def send_spawn_green_orb
    info 'spawn green orb'
    @client.text JSON.dump({:token => @user, :op => 'spawn_orb', :color => 'green'})
  end

  def send_spawn_black_orb
    @client.text JSON.dump({:token => @user, :op => 'spawn_orb', :color => 'black'})
  end
end

client = OrbsClient.new
# client.send_spawn_green_orb
# sleep(1)
# client.send_spawn_green_orb

# loop do
#   sleep(1)
#   client.send_spawn_green_orb
#   sleep(1)
#   client.send_spawn_black_orb
# end

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

