class Application
  constructor: () ->
    @user_id = null
    @user_name = null
    @active_unit_id = null
    @units = {}
    @my_units_ids = []
    @my_units = {}
    @options = new Options
    @controls = new Controls this
    @ws = new WS this
    @initialized = false
    @attacking = false
    # two-dimensional array of map tiles
    @cells = null
    @observer_registry = []
    @limit_info = new ElementProxy '#user-info-limit-value', ''
    # initialialized from server
    @max_cell_idx = null

  get_cell: (x, y) ->
    if @cells[x] && @cells[x][y] then @cells[x][y] else null

  # ws
  move: (params) ->
    @ws.move(@active_unit_id, params)

  give: (from, to, inventory) ->
    @ws.give(from, to, inventory)

  take: (to, from, inventory) ->
    @ws.take(to, from, inventory)

  fetch: () ->
    @ws.units()

  settle_town: () ->
    @ws.settle_town(@active_unit_id)

  restart: () ->
    @ws.restart()

  build: (id) ->
    @ws.build(id)

  disband: (id) ->
    @ws.disband(id)

  rename_unit: (id, name) ->
    @ws.rename_unit(id, name)

  hire_unit: (unit_type) ->
    @ws.hire_unit(unit_type)

  set_worker_to_xy: (town_id, worker_pos, x, y) ->
    @ws.set_worker_to_xy(town_id, worker_pos, x, y)

  # test, admin methods
  spawn_dummy_near: (x, y) ->
    @ws.spawn_dummy_near(x, y)

  provoke_dummy_attack: () ->
    @ws.provoke_dummy_attack()

  kill: (id) ->
    @ws.kill(id)

  ## interface
  set_active_unit_directly: (unit_id) ->
    @controls.set_active_unit(unit_id)

  update_user_info: (turn, unit_count, unit_limit, user_name = null) ->
    $('#user-info-turn-value').html(turn)
    if user_name && user_name != @user_name
      $('#user-info-nickname-value').html(user_name)
    @limit_info.update "#{unit_count}/#{unit_limit}"

  lock_controls: () ->
    @controls.lock_controls()

  unlock_controls: () ->
    # calc only alive units
    if @initialized and @my_units_ids.length > 0
      @controls.unlock_controls()

  set_active_unit: (unit_id) ->
    @active_unit_id = unit_id
    @controls.set_active_unit(@active_unit_id)
    @center_on_active()
    @bind_action_handlers()

  center_on_active: () ->
    @map.center_on_hero('unit-' + @active_unit_id)

  ##
  # update or create units on map
  # @param {Object} units - plain objects(hashes) to be transformed into Town, Squad etc
  upcreate_units: (units) ->
    # @units = {} # models
    # @my_units = {} # models
    # delete deleted, invisible units that present in units(new) but absent in @units(present)
    for unit_id_on_map, unit_on_map of @units
      if !units[unit_id_on_map]
        if @units[unit_id_on_map]
          @units[unit_id_on_map].remove()
          delete @units[unit_id_on_map]
        if @my_units[unit_id_on_map]
          delete @my_units[unit_id_on_map]
    for unit_id, unit_hash of units
      try
        unit_model = @units[unit_id]
        is_user_unit = unit_hash.user_id == @user_id
        if unit_model
          unit_model.update(unit_hash)
          unit_model.update_view()
          unit_model.update_controls()
          unit_model.update_modal()
          unit_model.update_buildings(unit_hash)
        else
          unit_model = new Unit(unit_hash, is_user_unit)
          unit_model.update(unit_hash)
          # if !unit_model.dead
          unit_model.create_view()
          unit_model.create_controls()
          unit_model.update_controls()
          unit_model.create_modal()
          unit_model.update_modal()
          @units[unit_id] = unit_model
        if unit_model.need_to_move
          @map.append_element_to_tile unit_model.view.element, unit_model.x, unit_model.y
          unit_model.need_to_move = false
        if is_user_unit
          @my_units[unit_id] = unit_model
      catch Error
        console.error(Error)
    @bind_action_handlers()
    @my_units_ids = (parseInt(id) for id, unit of @my_units)
    for x in [1..@max_cell_idx]
      for y in [1..@max_cell_idx]
        fog_of_war = true
        for id, unit of @my_units
          if unit.spotted x, y
            fog_of_war = false
            break
        @map.fog_of_war x, y, fog_of_war

    ObserverRegistry.publish('units', @units)
    true

  bind_action_handlers: () ->
    $('.attack-target').removeClass('attack-target').off('click')
    if @active_unit_id && @my_units[@active_unit_id]
      for dx in [-1..1]
        for dy in [-1..1]
          if dx || dy
            x = @my_units[@active_unit_id].x + dx
            y = @my_units[@active_unit_id].y + dy
            # there can be no cell across the border
            adj_cell = @get_cell(x, y)
            if adj_cell
              units = $(adj_cell.el).children('.unit.enemy')
              units.each((i, unit) ->
                $(unit)
                  .addClass('attack-target')
                  .off('click')
                  .one('click', () ->
                    App.attack(this)
                  )
              )

  attack: (unit) ->
    if !@attacking
      @attacking = true
      @ws.attack(@active_unit_id, $(unit).data('id'))

  init_user_controls: (actions) ->
    @controls.init_user_controls(actions)

  update_user_controls: (actions) ->
    @controls.update_user_controls(actions)

  log: (data) ->
    log_entry = $(document.createElement('div'))
      .append($(document.createElement('time')).html(data.time))
      .append($(document.createElement('span')).html(data.message))
      .prependTo('#log')
      .addClass(data.type)
      .addClass('log-entry')
      .addClass('new-log-entry')
      setTimeout(() ->
        log_entry.removeClass('new-log-entry')
      , 2000)

  error: (message) ->
    @log {message: message, type: 'error', time: ''}

  is_valid_coordinates: (x, y) ->
    @max_cell_idx >= x > 0 && @max_cell_idx >= y > 0

window.App = new Application
