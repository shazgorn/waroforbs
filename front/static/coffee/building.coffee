class Building
  constructor: (key, building) ->
    @id = key
    @name = building['name']
    @title = building['title']
    @status = building['status']
    @ttb_string = building['ttb_string']
    @cost_res = building['cost_res']
    @actions = building['actions']

  update: (building) ->
    @status = building['status']
    @ttb_string = building['ttb_string']

window.Building = Building
