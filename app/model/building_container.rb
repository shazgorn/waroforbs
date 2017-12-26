##
# Read-only wrapper for for workers

class BuildingContainer
  def initialize(buildings)
    @buildings = buildings
  end

  def get_levels(res_type)
    [@buildings[Config[:resource][res_type][:production_building]].level, @buildings[:roads].level]
  end
end
