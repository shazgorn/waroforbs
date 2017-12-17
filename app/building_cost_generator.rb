##
# Generate buildings level costs based on formula

class BuildingCostGenerator
  def initialize(buildings)
    @buildings = buildings
  end

  def generate_buildings_cost
    @buildings.each_key{|name|
      generate_building_cost(name)
    }
  end

  def default_cost
    {'time' => 0, 'res' => {}}
  end

  def generate_building_cost(name)
    bconfig = @buildings[name]
    current_formula = nil
    prev_cost = default_cost
    (1..bconfig['max_level']).each{|level|
      raise OrbError, 'No formula for level 1 of #{name}' if level == 1 && bconfig['cost']['formula'][level].nil?
      if bconfig['cost']['formula'][level]
        current_formula = bconfig['cost']['formula'][level]
      end
      # skip building cost set manually
      if bconfig['cost'][level]
        prev_cost = bconfig['cost'][level]
      else
        prev_cost = parse_formula_and_apply prev_cost, current_formula
        bconfig['cost'][level] = prev_cost.clone
      end
    }
  end

  ##
  # {cost} - hash

  def parse_formula_and_apply prev_cost, formula
    new_cost = default_cost
    formula['res'].each{|res, exp|
      if exp.respond_to? :split
        tokens = exp.split(' ')
        if prev_cost['res'][res]
          prev_value = prev_cost['res'][res]
        else
          # resource cost widening
          case tokens[0]
          when '+'
            prev_value = 0
          when '*'
            # zero multiplication seems useless
            prev_value = 1
          end
        end
        new_cost['res'][res] = prev_value.send tokens[0].to_sym, tokens[1].to_i
      else
        new_cost['res'][res] = exp
      end
    }
    if formula['time'].respond_to? :split
      tokens = formula['time'].split(' ')
      new_cost['time'] = prev_cost['time'].send tokens[0].to_sym, tokens[1].to_i
    else
      new_cost['time'] = formula['time']
    end
    new_cost
  end
end
