require 'prime'

class TownAid
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  def initialize(town)
    @town = town
    @awakenenings = 0
    @town_aids = 0
    @online = true

    subscribe('user_auth', :user_auth)
    subscribe('user_quit', :user_quit)
  end

  def user_auth(topic, user_id)
    if @town.user.id == user_id
      @online = true
    end
  end

  def user_quit(topic, user_id)
    if @town.user.id == user_id
      @online = false
    end
  end

  def run
    info "Town aid for town id=#{@town.id} started"
    now = Time.now.to_f
    sleep now.ceil - now + 0.001
    every(Config[:res_spawner_tick]) do
      aid
    end
  end

  ##
  # Spawn loot boxes or resources for online users only

  def aid
    if @online
      @awakenenings += 1
      if Prime.prime? @awakenenings
        if @town_aids % 2 == 0
          class_to_spawn = Resource
        else
          class_to_spawn = Chest
        end
        info 'publish spawn_random_res_near'
        publish 'spawn_random_res_near', @town, class_to_spawn
        @town_aids += 1
      end
      if @town_aids > Config[:max_town_aid]
        terminate
      end
    end
  end
end
