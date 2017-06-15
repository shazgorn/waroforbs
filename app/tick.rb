module Tick
  def run_clock
    Thread.new do
      while true
        begin
          @game.tick
        rescue => e
          ex e
        end
        sleep(3)
      end
    end
  end
end
