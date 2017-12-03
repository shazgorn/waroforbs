class OrbTick
  TICK_TIME = 3
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  def initialize
    async.run
  end

  def run
    @monolith_spawned = false
    info 'Tick started'
    now = Time.now.to_f
    sleep now.ceil - now + 0.001
    every(TICK_TIME) do
      unless @monolith_spawned
        publish 'spawn_monolith'
      end
      publish 'tick'
    end
  end
end
