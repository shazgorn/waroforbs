require 'game'
require 'pp'

RSpec.describe ElfSpawner, "testing" do
  around do |ex|
    Celluloid.boot
    Token.drop_all
    Celluloid::Actor[:map] = Map.new
    Celluloid::Actor[:elf_spawner] = ElfSpawner.new
    ex.run
    Celluloid.shutdown
  end

  it 'spawning elves' do
    Celluloid::Actor[:elf_spawner].spawn_elf
    sleep(Config[:spawn_elf_every])
    expect(ElfSwordsman.get_by_type(ElfSwordsman::TYPE).length).to be > 0
  end
end
