require 'game'

RSpec.describe SquadAttack, "is attacking" do
  around do |ex|
    Celluloid.boot
    Celluloid::Actor[:game] = Game.new
    ex.run
    Celluloid.shutdown
  end

  it 'attack times' do
    a_user = User.new('attacker')
    a = HeavyInfantry.new(1, 1, a_user)
    d_user = User.new('defender')
    d = HeavyInfantry.new(2, 2, d_user)
    res = SquadAttack.attack_times(a, d)
    res = SquadAttack.attack_times(a, d)
    res = SquadAttack.attack_times(a, d)
    res = SquadAttack.attack_times(a, d)
    res = SquadAttack.attack_times(a, d)
  end
end
