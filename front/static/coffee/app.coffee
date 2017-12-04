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
    @cells = null
    @current_glory = null

  update_user_info: (turn, user_glory, user_max_glory, user_name = null) ->
    $('#user-info-turn-value').html(turn)
    if user_name && user_name != @user_name
      $('#user-info-nickname-value').html(user_name)
    if user_glory? and user_max_glory?
      new_glory = "#{user_glory}/#{user_max_glory}"
      if @current_glory != new_glory
        @current_glory = new_glory
        $('#user-info-glory-value').html(@current_glory)

  move: (params) ->
    @ws.move(@active_unit_id, params)

  lock_controls: () ->
    @controls.lock_controls()

  unlock_controls: () ->
    # calc only alive units
    if @initialized and @my_units_ids.length > 0
      @controls.unlock_controls()

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

  spawn_dummy_near: (x, y) ->
    @ws.spawn_dummy_near(x, y)

  add_squad_to_squad: (squad_id) ->
    @ws.add_squad_to_squad(squad_id, @town_controls.last_town)

  set_worker_to_xy: (town_id, worker_pos, x, y) ->
    @ws.set_worker_to_xy(town_id, worker_pos, x, y)

  set_active_unit_directly: (unit_id) ->
    @controls.set_active_unit(unit_id)

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
      if !units[unit_id_on_map] && @units[unit_id_on_map]
        @units[unit_id_on_map].remove()
        delete @units[unit_id_on_map]
    for unit_id, unit_hash of units
      try
        unit_model = @units[unit_id]
        is_user_unit = unit_hash.user_id == @user_id
        if unit_model
          unit_model.update(unit_hash)
          unit_model.update_view()
          unit_model.update_controls()
          unit_model.update_modal(unit_hash)
          unit_model.update_buildings(unit_hash)
        else
          unit_model = new Unit(unit_hash, is_user_unit)
          unit_model.update(unit_hash)
          if !unit_model.dead
            unit_model.create_view()
            unit_model.create_controls()
            unit_model.update_controls()
            unit_model.create_modal()
          @units[unit_id] = unit_model
        if unit_model.need_to_move
          @map.appendElementToCell(unit_model.view.element, unit_model.x, unit_model.y)
          unit_model.need_to_move = false
        if is_user_unit
          @my_units[unit_id] = unit_model
      catch Error
        console.error(Error)
    @bind_action_handlers()
    @my_units_ids = (parseInt(id) for id, unit of @my_units)
    true

  # bind attack handlers
  bind_action_handlers: () ->
    $('.attack-target').removeClass('attack-target').off('click')
    cell = $('#unit-' + @active_unit_id).parent()
    if cell.length == 1
      xy = cell.attr('id').replace('cell_', '').split('_')
      for dx in [-1..1]
        for dy in [-1..1]
          if dx || dy
            x = parseInt(xy[0]) + dx
            y = parseInt(xy[1]) + dy
            adj_cell = $('#cell_' + x + '_' + y)
            unit = adj_cell.children('div').get(0)
            if unit
              # do not attack our own
              if $(unit).hasClass('enemy')
                $(unit)
                  .addClass('attack-target')
                  .off('click')
                  .one('click', () ->
                    App.attack(this)
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

window.App = new Application
