class ElfSpawner
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Internals::Logger

  def initialize
    @elf_user = User.new(I18n.t(Config.get(:elf_login)))
  end

  def run
    info 'Elf spawner started'
    now = Time.now.to_f
    sleep now.ceil - now + 0.001
    every(Config[:spawn_elf_every]) do
      spawn_elf
    end
  end

  def spawn_elf
    Celluloid::Actor[:map].each_tile{|tile|
      if tile.type == :tree && Unit.get_by_xy(tile.x, tile.y).nil?
        if rand(100) > 90
          info 'spawn elf'
          ElfSwordsman.new tile.x, tile.y, @elf_user
        end
      end
    }
  end
end
