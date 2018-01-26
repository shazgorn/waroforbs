class ElfSpawner
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  def run
    info 'Elf spawner started'
    now = Time.now.to_f
    sleep now.ceil - now + 0.001
    every(Config[:spawn_elf_every]) do
      if Config[:spawn_elves]
        info 'publish spawn_elf'
        publish 'spawn_elf'
      end
    end
  end
end
