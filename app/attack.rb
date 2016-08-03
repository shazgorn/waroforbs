class Attack
  KILLED = 'Your hero has been killed'

  def self.attack a, d
    res = {
      :a_data => {
        :dead => false
      },
      :d_data => {
        :dead => false
      }
    }

    if a.nil?
      res[:a_data][:log] = 'Your hero is dead'
      return res
    end
    
    dmg = nil
    if d && a != d && a.ap >= 1
      dmg = d.take_dmg a.dmg
      a.ap -= 1
      if d.dead?
        res[:d_data][:log] = KILLED
        res[:d_data][:dead] = true
        ca_dmg = 0
      else
        ca_dmg = a.take_dmg d.dmg
        if a.dead?
          res[:a_data][:log] = KILLED
          res[:a_data][:dead] = true
        end
      end

      if d.user
        res[:d_user] = d.user
        res[:d_data].merge!({
                              :data_type => 'dmg',
                              :id => d.id,
                              :dmg => ca_dmg,
                              :ca_dmg => dmg
                            })
      end
    end
    res[:a_data].merge!({:dmg => dmg, :ca_dmg => ca_dmg})
    res
  end
end
