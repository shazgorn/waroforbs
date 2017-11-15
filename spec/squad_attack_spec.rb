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
      res = SquadAttack.new.attack(a, d)
      a_total_dmg += res[:a_dmg][:kills] + res[:a_dmg][:wounds]
      if res[:a_dmg][:killed]
        expect(a_total_dmg).to eq(Config.get('MAX_LIFE'))
        break
      end
      d_total_dmg += res[:d_dmg][:kills] + res[:d_dmg][:wounds]
      if res[:d_dmg][:killed]
        expect(d_total_dmg).to eq(Config.get('MAX_LIFE'))
        break
      end
    }
  end
end
