class SquadAttack
  def initialize(a, d)
    @a = a
    @d = d
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

  def attack
    # d_casualties - damage dealt to defender (casualties)
    # a_casualties - damage dealt to attacker (casualties)
    attack_phase
    @res[:d_casualties][:killed] = @d.dead?
    @res[:a_casualties][:killed] = @a.dead?
    @res[:a_id] = @a.id
    @res[:d_id] = @d.id
    @res
  end

  def attack_phase
    a_times = @a.strength
    d_times = @d.strength
    a_times.times{|i|
      return if @a.dead? || @d.dead?
      single_attack_on(@d, :d_casualties, @a.attack, @d.defence)
      # retaliation
      single_attack_on(@a, :a_casualties, @d.attack, @a.defence)
      d_times -= 1 if d_times
    }
    # continue retaliation if defender has more lifes than attacker
    d_times.times{|i|
      return if @a.dead? || @d.dead?
      single_attack_on(@a, :a_casualties, @d.attack, @a.defence)
    }
  end

  def single_attack_on(d, index, attack, defence)
    roll(attack, defence)
    if kill?
      # for SE kills became wounds
      if d.kill
        @res[index][:kills] += 1
      else
        @res[index][:wounds] += 1
      end
    elsif wound?
      d.wound
      @res[index][:wounds] += 1
    end
  end

  def roll(attack, defence)
    if attack
      @prob = rand(100) * defence / attack
    else
      @prob = 100
    end
  end

  def kill?
    @prob < 6
  end

  def wound?
    @prob < 25
  end
end
