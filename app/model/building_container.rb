##
# Read-only wrapper for for workers

class BuildingContainer
  def initialize(buildings)
    @buildings = buildings
  end

  def get_levels(res_type)
    [@buildings[Config['resource'][res_type.to_s]['production_building'].to_sym].level, @buildings[:roads].level]
  end
end
