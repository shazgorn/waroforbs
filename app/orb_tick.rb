class OrbTick
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  def initialize
    async.run
  end

  def run
    info 'Tick started'
    now = Time.now.to_f
    sleep now.ceil - now + 0.001
    every(3) do
      publish 'tick'
    end
  end
end
