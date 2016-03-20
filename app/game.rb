# this class gotta contain some logic about units interactions
# and all other non-map things
# dead heroes are dead if they never exists
class Game
  attr_reader :map
  attr_accessor :users

  def initialize
    @users = Hash.new
    @map = Map.new
  end

  def init_user token, ws
    if @users.key? token
      user = @users[token]
      user.ws = ws
    else
      @users[token] = user = User.new(token)
      user.ws = ws
    end
    # find active unit from @active_unit_id or iterate over user.heroes to find !nil & !dead
    if user.heroes.length == 1 && user.hero.pos.nil?
      place_at_random user.hero
    end
    user
  end

  def collect_scores
    @users.values.collect{|user| {
                            :login => user.login,
                            :score => user.score}}.sort{|a, b| b[:score] <=> a[:score]}
  end
  
  def bury(unit)
    @map.remove unit
    @users[unit.user].heroes.delete(unit.id)
  end

  def revive(token)
    user = @users[token]
    unit = user.hero
    if unit.dead?
      @users[unit.user].hero = hero = Hero.new(unit.user)
      place_at_random hero
    end
  end

  def new_hero(token)
    user = @users[token]
    hero = user.add_hero
    place_at_random hero
  end

  def move_hero_by token, hero_id, dx, dy
    res = {:log => nil, :moved => false}
    user = @users[token]
    hero = user.heroes[hero_id]
    if hero.alive?
      res[:moved] = @map.move_by hero, dx, dy
    else
      puts 'Risen dead'
      res[:log] = 'Your hero is dead'
    end
    res
  end

  def place_at_random hero
    if hero.alive?
      @map.place_at_random hero
    end
  end
  
  # a - attacker, {x,y} defender`s coordinates
  def attack token, active_unit_id, x, y
    a_user = @users[token]
    a = a_user.heroes[active_unit_id]
    a_pos = a.pos
    res = {
      :a_data => {},
      :d_data => {}
    }
    if @map.has?(x, y)
      d = @map.at(x, y)
      d_user = d.user
      dmg = nil
      if d && a != d
        dmg = d.take_dmg a.dmg
        if d.dead?
          bury d
          res[:d_data][:log] = 'Your hero has been killed'
          ca_dmg = 0
        else
          ca_dmg = a.take_dmg d.dmg
          if a.dead?
            bury a
            res[:a_data][:log] = 'Your hero has been killed'
          end
        end
        if d_user && !d.user.ws.nil?
          xy = @map.h2c a_pos
          res[:d_user] = d_user
          res[:d_data].merge!({
                                :data_type => 'dmg',
                                :x => xy[:x],
                                :y => xy[:y],
                                :dmg => ca_dmg,
                                :ca_dmg => dmg
                              })
        end
      end
    end
    res[:a_data].merge!({:dmg => dmg, :ca_dmg => ca_dmg})
    res
  end
  
end

