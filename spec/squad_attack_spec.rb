require 'game'

RSpec.describe SquadAttack, "is attacking" do
  around do |ex|
    Celluloid.boot
    Celluloid::Actor[:game] = Game.new(true)
    ex.run
    Celluloid.shutdown
  end

  it 'attack times' do
    a_user = User.new('attacker')
    a = Swordsman.new(1, 1, a_user)
    d_user = User.new('defender')
    d = Swordsman.new(2, 2, d_user)
    res = SquadAttack.attack_times(a, d)
    res = SquadAttack.attack_times(a, d)
    res = SquadAttack.attack_times(a, d)
    res = SquadAttack.attack_times(a, d)
    res = SquadAttack.attack_times(a, d)
  end
end
