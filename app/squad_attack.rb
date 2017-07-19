class SquadAttack

  ##
  # a - attacker
  # d - defender

  def self.attack(a, d)
    srand(0)
    a_res = attack_times(a, d)
    if d.alive?
      d_res = attack_times(d, a)
    end
  end

  def self.attack_times(a, d)
    wounds = 0
    kills = 0
    a.life.times {|n|
      prob = rand(100)
      if prob < 6
        puts 'kill'
        d.kill
        kills += 1
      elsif prob < 25
        puts 'wound'
        d.wound
        wounds += 1
      end
      break if d.dead?
    }
    [:kills => kills, :wounds => wounds]
  end
end
