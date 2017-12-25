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
    a_total_dmg = 0
    d_total_dmg = 0
    7.times {|i|
      res = SquadAttack.new(a, d).attack
      a_total_dmg += res[:a_casualties][:kills] + res[:a_casualties][:wounds]
      if res[:a_casualties][:killed]
        expect(a_total_dmg).to eq(Config.get(:max_life))
        break
      end
      d_total_dmg += res[:d_casualties][:kills] + res[:d_casualties][:wounds]
      if res[:d_casualties][:killed]
        expect(d_total_dmg).to eq(Config.get(:max_life))
        break
      end
    }
  end
end
