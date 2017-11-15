class SquadAttack

  def initialize
    @res = {
      :a_dmg => {
        :kills => 0,
        :wounds => 0
      },
      :d_dmg => {
        :kills => 0,
        :wounds => 0
      }
    }
  end

  ##
  # +a+ - attacker Unit
  # +d+ - defender Unit

  def attack(a, d)
    srand(0)
    # d_dmg - damage dealt to defender (casualties)
    # a_dmg - damage dealt to attacker (casualties)
    attack_phase(a, d)
    @res[:d_dmg][:killed] = d.dead?
    @res[:a_dmg][:killed] = a.dead?
    @res[:a_id] = a.id
    @res[:d_id] = d.id
    @res
  end

  def attack_phase(a, d)
    a_times = a.strength
    d_times = d.strength
    a_times.times{|i|
      return if a.dead? || d.dead?
      single_attack(d, :d_dmg)
      single_attack(a, :a_dmg)
      d_times -= 1 if d_times
    }
    d_times.times{|i|
      return if a.dead? || d.dead?
      single_attack(a, :a_dmg)
    }
  end

  def single_attack(unit, index)
    roll
    if kill?
      # for SE kills became wounds
      if unit.kill
        @res[index][:kills] += 1
      else
        @res[index][:wounds] += 1
      end
    elsif wound?
      unit.wound
      @res[index][:wounds] += 1
    end
  end

  def roll
    @prob = rand(100)    
  end

  def kill?
    @prob < 6
  end

  def wound?
    @prob < 25
  end
end
