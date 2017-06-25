class OrbTick
  include Celluloid
  include Celluloid::Notifications

  def initialize
    async.run
  end

  def run
    now = Time.now.to_f
    sleep now.ceil - now + 0.001
    every(3) do
      publish 'tick'
    end
  end
end
