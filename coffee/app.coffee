class Application
  constructor: () ->
    @user_id = null
    @active_unit_id = null
    @units = {}
    @my_units_ids = []
    @my_units = {}
    @banners = []
    @options = new Options
    @controls = new Controls this
    @town_controls = new TownControls this
    @ws = new WS this
    @initialized = false
    @attacking = false
    @cells = null
    @TOWN_RADIUS = null

  move: (params) ->
    @ws.move(@active_unit_id, params)

  lock_controls: () ->
    @controls.lock_controls()

  unlock_controls: () ->
    if @initialized and @my_units_ids.length > 0
      @controls.unlock_controls()

  new_hero: () ->
    @ws.new_hero()

  new_town: () ->
    @ws.new_town(@active_unit_id)

  restart: () ->
    @ws.restart()

  build: (button) ->
    id = $(button).data('id')
    @ws.build(id)

  disband: (id) ->
    @ws.disband(id)

  create_random_banner: () ->
    @ws.create_random_banner()

  create_default_company: () ->
    @ws.create_default_company()

  create_company_from_banner: (banner_id) ->
    @ws.create_company_from_banner(banner_id)

  add_squad_to_company: (company_id) ->
    @ws.add_squad_to_company(company_id, @town_controls.last_town)

  delete_banner: (banner_id) ->
    @ws.delete_banner(banner_id)

  set_free_worker_to_xy: (town_id, x, y) ->
    @ws.set_free_worker_to_xy(town_id, x, y)

  free_worker: (town_id, x, y) ->
    @ws.free_worker(town_id, x, y)

  refresh_modals: () ->
    id = @town_controls.open_building_id
    if id
      @town_controls.fill_building_modal(id)

  set_active_unit_directly: (unit_id) ->
    @controls.set_active_unit(unit_id)

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
    @units = {}
    @my_units = {}
    for unit_id, unit_hash of units
      try
        unit_obj = UnitFactory(unit_hash, @user_id)
        if unit_obj
          @units[unit_obj.id] = unit_obj
          unit_on_map = @map.append(unit_obj)
          if unit_hash['@user_id'] == @user_id
            @my_units[unit_obj.id] = unit_obj
            @controls.unit_info(unit_hash)
            @bind_select_handler(unit_on_map)
          unit_obj.init()
      catch Error
        console.log(Error)
    @bind_action_handlers()
    @my_units_ids = (parseInt(id) for id, unit of @my_units)
    # delete dead units
    if @my_units_ids.length == 0
      @lock_controls()
    $('.unit-info:not(.unit-info-template)').each((i, el) =>
      id = $(el).data('id')
      if $.inArray(id, @my_units_ids) == -1
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
                $(unit)
                  .addClass('attack-target')
                  .off('click')
                  .one('click', () ->
                    App.attack(this)
                  )

  attack: (unit) ->
    if !@attacking
      @attacking = true
      @ws.attack(@active_unit_id, {id: $(unit).data('id')})

  # select unit or open town modal screen
  bind_select_handler: (unit) ->
    $(unit).addClass('select-target').off('click').on('click', () =>
      @set_active_unit($(unit).data('id'))
      if $(unit).hasClass('player-town')
        @town_controls.open_town($(unit).data('id'))
    )

  init_user_controls: (actions) ->
    @controls.init_user_controls(actions)

  init_town_buildings: (buildings) ->
    @town_controls.init_town_buildings(buildings)

  init_town_controls: (actions) ->
    @town_controls.init_town_controls(actions)

  init_town_workers: (town) ->
    @town_controls.init_town_workers(town)

  init_town_inventory: (inventory) ->
    @town_controls.init_town_inventory(inventory)

  log: (data) ->
    log_entry = $(document.createElement('div'))
      .html(data)
      .prependTo('#log')
      .addClass('log-entry')
      .addClass('new-log-entry')
      setTimeout(() ->
        log_entry.removeClass('new-log-entry')
      , 2000)

window.App = new Application
