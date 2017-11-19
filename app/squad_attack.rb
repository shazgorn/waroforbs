class SquadAttack

  def initialize
    @res = {
      :a_casualties => {
        :kills => 0,
        :wounds => 0
      },
      :d_casualties => {
        :kills => 0,
        :wounds => 0
      }
    }
  end

  ##
  # +a+ - attacker Unit
  # +d+ - defender Unit

  def attack(a, d)
    # d_casualties - damage dealt to defender (casualties)
    # a_casualties - damage dealt to attacker (casualties)
    attack_phase(a, d)
    @res[:d_casualties][:killed] = d.dead?
    @res[:a_casualties][:killed] = a.dead?
    @res[:a_id] = a.id
    @res[:d_id] = d.id
    @res
  end

  def attack_phase(a, d)
    a_times = a.strength
    d_times = d.strength
    a_times.times{|i|
      return if a.dead? || d.dead?
      single_attack(d, :d_casualties)
      single_attack(a, :a_casualties)
      d_times -= 1 if d_times
    }
    d_times.times{|i|
      return if a.dead? || d.dead?
      single_attack(a, :a_casualties)
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
