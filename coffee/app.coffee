class Application
  constructor: () ->
    @user_id = null
    @active_unit_id = null
    @units = []
    @my_units = []
    @banners = []
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

  new_town_hero: () ->
    @ws.new_town_hero()

  restart: () ->
    @ws.restart()

  build: (button) ->
    id = $(button).data('id')
    @ws.build(id)

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
    true

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
              if !$(unit).hasClass('player-unit')
                $(unit).addClass('attack-target').off('click').one('click', () ->
                  App.attack(this)
                )

  attack: (unit) ->
    if !@attacking
      @attacking = true
      @ws.attack(@active_unit_id, {id: $(unit).data('id')})

  bind_select_handler: (unit) ->
    $(unit).addClass('select-target').off('click').on('click', () =>
      @set_active_unit($(unit).data('id'))
      if $(unit).hasClass('player-town')
        $('.modal.town').show()
    )

  init_town_buildings: (buildings) ->
    @controls.init_town_buildings(buildings)

  log: (data) ->
    div = document.createElement('div')
    div.innerHTML = data
    $(div).prependTo('#log')

window.App = new Application
