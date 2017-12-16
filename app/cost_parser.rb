class CostParser #module?
  class << self
    # got some cache?
    @@costs = {}

    ##
    # {cost} - hash

    def parse cost, level, bname
      new_cost = cost.clone
      cost['res'].each{|res, exp|
        if exp.respond_to? :split
          tokens = exp.split(' ')
          if tokens.length == 2
            prev_cost = find_cost bname, level - 1
            new_cost['res'][res] = tokens[1].to_i
            if prev_cost['res'][res]
              new_cost['res'][res] = prev_cost['res'][res].send tokens[0].to_sym, new_cost['res'][res]
            end
          end
        end
      }
      if cost['time'].respond_to? :split
          tokens = cost['time'].split(' ')
          if tokens.length == 2
            prev_cost = find_cost bname, level - 1
            new_cost['time'] = prev_cost['time'].send tokens[0].to_sym, tokens[1].to_i
          end
      end
      new_cost
    end

    def find_cost(bname, level)
      raise OrbError, "Cost not found for #{bname} #{@level+1}"  if level < 1
      cost = Config[bname]['cost_levels'][level]
      if cost
        return parse cost, level, bname
      else
        return find_cost bname, level - 1
      end
    end
  end
end
