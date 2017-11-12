class SquadAttack

  ##
  # a - attacker
  # d - defender

  def self.attack(a, d)
    srand(0)
    d_dmg = attack_times(a, d)
    a_dmg = attack_times(d, a)
    d_dmg[:dead] = a.dead?
    a_dmg[:dead] = d.dead?
    res = {:a_dmg => a_dmg, :d_dmg => d_dmg}
    res[:a_id] = a.id
    res[:d_id] = d.id
    res
  end

  ##
  # Return damage inflicted on +d+ unit

  def self.attack_times(a, d)
    wounds = 0
    kills = 0
    if a.alive?
      a.life.times {|n|
        prob = rand(100)
        if prob < 6
          # for SE kills became wounds
          if d.kill
            kills += 1
          else
            wounds += 1
          end
        elsif prob < 25
          d.wound
          wounds += 1
        end
        break if d.dead?
      }
    end
    {:kills => kills, :wounds => wounds}
  end
end
