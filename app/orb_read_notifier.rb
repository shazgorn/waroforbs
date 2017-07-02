# TODO: drop it
class OrbReadNotifier
  include Celluloid
  include Celluloid::Notifications

  def initialize
    async.run
  end

  def run
    now = Time.now.to_f
    sleep now.ceil - now + 0.001
    every(1) do 
      publish 'read_message'
    end
  end
end
