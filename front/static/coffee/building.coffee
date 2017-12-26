class Building
  constructor: (key, building) ->
    @id = key
    @type = building['type']
    @name = building['name']
    @status = building['status']
    @ttb_string = building['ttb_string']
    @cost_res = building['cost_res']
    @actions = building['actions']
    @build_label = building.build_label
    @level = building.level
    @max_level = building.max_level

  update: (building) ->
    @status = building.status
    @ttb_string = building.ttb_string
    @build_label = building.build_label
    @level = building.level

window.Building = Building
