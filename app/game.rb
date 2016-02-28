# this class gotta contain some logic about units interactions
# and all other non-map things
class Game
  attr_reader :map
  attr_accessor :users

  def initialize
    @users = Hash.new
    @map = Map.new
  end

  def collect_scores
    @users.values.collect{|user| {
                            :login => user.login,
                            :score => user.score}}.sort{|a, b| b[:score] <=> a[:score]}
  end
  
  def bury(unit)
    @map.remove unit
  end

  def revive(unit)
    if unit.user
      @users[unit.user].hero = hero = Hero.new(unit.user)
      @map.place_at_random hero
    end
  end
  
  # a - attacker, {x,y} defender`s coordinates
  def attack(a, x, y)
    res = {}
    if @map.has?(x, y)
      d = @map.at(x, y)
      dmg = nil
      if d && a != d
        dmg = d.take_dmg a.dmg
        if d.dead?
          bury d
          if a.user
            @users[a.user].inc_score d.score
          end
          ca_dmg = 0
        else
          ca_dmg = a.take_dmg d.dmg
          if a.dead?
            bury a
          end
        end
        if d.user && @users[d.user] && !@users[d.user].ws.nil?
          xy = @map.h2c a.pos
          res[:d] = d
          res[:d_data] = {:data_type => 'dmg',
                     :x => xy[:x],
                     :y => xy[:y],
                     :dmg => ca_dmg,
                     :ca_dmg => dmg}
        end
      end
    end
    res[:a_data] = {:dmg => dmg, :ca_dmg => ca_dmg}
    res
  end
  
end

