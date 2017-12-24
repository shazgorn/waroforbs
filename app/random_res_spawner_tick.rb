class RandomResSpawnerTick
  TICK_TIME = 3
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  def initialize
    async.run
  end

  def run
    info 'Random res spawner tick started'
    now = Time.now.to_f
    sleep now.ceil - now + 0.001
    every(TICK_TIME) do
      publish 'spawn_random_res'
    end
  end
end
