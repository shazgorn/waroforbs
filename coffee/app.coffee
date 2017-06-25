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
    # calc only alive units
    if @initialized and @my_units_ids.length > 0
      @controls.unlock_controls()

  fetch: () ->
    @ws.units()

  new_hero: () ->
    @ws.new_hero()

  new_town: () ->
    @ws.new_town(@active_unit_id)

  restart: () ->
    @ws.restart()

  build: (id) ->
    @ws.build(id)

  dismiss: (id) ->
    @ws.dismiss(id)

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
    # id = @town_controls.open_building_id
    # if id
    #   @town_controls.fill_building_modal(id)
    return

  set_active_unit_directly: (unit_id) ->
    @controls.set_active_unit(unit_id)

  set_active_unit: (unit_id) ->
    @active_unit_id = unit_id
    @controls.set_active_unit(@active_unit_id)
    @center_on_active()
    @bind_action_handlers()

  center_on_active: () ->
    @map.center_on_hero('unit-' + @active_unit_id)

  init_units: (units) ->
    # @map.remove_stale_units(units)
    # @units = {} # models
    # @my_units = {} # models
    for unit_id, unit_hash of units
      try
        unit_model = @units[unit_id]
        is_user_unit = unit_hash['@user_id'] == @user_id
        if unit_model
          unit_model.update unit_hash
        else
          unit_model = UnitFactory(unit_hash, is_user_unit)
          if !unit_model.dead
            unit_model.create_view()
          @units[unit_id] = unit_model
        if unit_model.need_to_move
          @map.appendElementToCell(unit_model.view.element, unit_model.x, unit_model.y)
          unit_model.need_to_move = false
        if is_user_unit
          @my_units[unit_id] = unit_model
      catch Error
        console.log(Error)
    @bind_action_handlers()
    @my_units_ids = (parseInt(id) for id, unit of @my_units)
    # delete dead units
    # if @my_units_ids.length == 0
    #   @lock_controls()
    # $('.unit-info:not(.unit-info-template)').each((i, el) =>
    #   id = $(el).data('id')
    #   if $.inArray(id, @my_units_ids) == -1
    #     $(el).remove()
    #     if id == @active_unit_id
    #       @lock_controls()
    # )
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

  init_user_controls: (actions) ->
    @controls.init_user_controls(actions)

  update_user_controls: (actions) ->
    @controls.update_user_controls(actions)

  log: (data) ->
    log_entry = $(document.createElement('div'))
      .append($(document.createElement('time')).html(data['@time']))
      .append($(document.createElement('span')).html(data['@message']))
      .prependTo('#log')
      .addClass(data['@type'])
      .addClass('log-entry')
      .addClass('new-log-entry')
      setTimeout(() ->
        log_entry.removeClass('new-log-entry')
      , 2000)

window.App = new Application
