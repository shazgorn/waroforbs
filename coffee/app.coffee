class Application
  constructor: () ->
    @user_id = null
    @active_unit_id = null
    @units = []
    @my_units = []
    @controls = new Controls this
    @ws = new WS this
    @initialized = false
    @attacking = false

  move: (params) ->
    @ws.move(@active_unit_id, params)

  lock_controls: () ->
    @controls.lock_controls()

  unlock_controls: () ->
    if @initialized and @my_units.length > 0
      @controls.unlock_controls()

  spawn_bot: (id) ->
    @ws.spawn_bot()

  revive: () ->
    @ws.revive()

  new_hero: () ->
    @ws.new_hero()

  new_town: () ->
    @ws.new_town(@active_unit_id)

  restart: () ->
    @ws.restart()

  set_active_unit: (unit_id) ->
    #if unit_id != @active_unit_id
    @active_unit_id = unit_id
    @controls.set_active_unit(@active_unit_id)
    @center_on_active()
    @bind_action_handlers()

  center_on_active: () ->
    @map.center_on_hero('unit-' + @active_unit_id)

  init_units: (units) ->
    @map.remove_stale_units(units)
    @units = []
    @my_units = []
    for unit_id, unit_hash of units
      unit_obj = UnitFactory(unit_hash, @user_id)
      if unit_obj
        @units.push(unit_obj)
        unit_on_map = @map.append(unit_obj)
        if unit_hash['@user_id'] == @user_id
          @my_units.push(unit_obj)
          @controls.unit_info(unit_hash)
          @bind_select_handler(unit_on_map)
    @bind_action_handlers()
    # delete dead units
    if @my_units.length == 0
      @lock_controls()
    my_units_ids = $.map(@my_units, (unit) ->
      unit.id
    )
    $('.unit-info:not(.unit-info-template)').each((i, el) =>
      id = $(el).data('id')
      if $.inArray(id, my_units_ids) == -1
        $(el).remove()
        if id == @active_unit_id
          @lock_controls()
    )
    null

  bind_action_handlers: () ->
    cell = $('#unit-' + @active_unit_id).parent()
    if cell.length == 1
      pos = cell.attr('id').replace('cell_', '').split('_')
      for dx in [-1..1]
        for dy in [-1..1]
          if dx || dy
            x = parseInt(pos[0]) + dx
            y = parseInt(pos[1]) + dy
            adj_cell = $('#cell_' + x + '_' + y)
            unit = adj_cell.children('div').get(0)
            if unit
              unless $(unit).hasClass('player-hero')
                $(unit).css('cursor', 'crosshair').off('click').one('click', () ->
                  App.attack(this)
                )

  attack: (unit) ->
    if !@attacking
      @attacking = true
      @ws.attack(@active_unit_id, {id: $(unit).data('id')})

  bind_select_handler: (unit) ->
    $(unit).css('cursor', 'pointer').off('click').on('click', () =>
      @set_active_unit($(unit).data('id'))
    )
    

  log: (data) ->
    div = document.createElement('div')
    div.innerHTML = data
    $(div).prependTo('#log')

window.App = new Application