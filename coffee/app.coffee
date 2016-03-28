class Application
  constructor: () ->
    @user_id = localStorage.getItem('user_id')
    @active_unit_id = null
    unless @user_id then location.pathname = '/'
    @units = []
    @my_units = []
    @controls = new Controls this
    @ws = new WS this
    @initialized = false
    @attacking = false

  move: (params) ->
    @ws.move(@user_id, @active_unit_id, params)

  lock_controls: () ->
    @controls.lock_controls()

  unlock_controls: () ->
    if @initialized and @my_units.length > 0
      @controls.unlock_controls()

  spawn_bot: (id) ->
    @ws.spawn_bot()

  revive: () ->
    @ws.revive(@user_id)

  new_hero: () ->
    @ws.new_hero(@user_id)

  new_town: () ->
    @ws.new_town(@user_id)

  set_active_unit: (unit_id) ->
    if unit_id != @active_unit_id
      @active_unit_id = unit_id
      @center_on_active()

  center_on_active: () ->
    @map.center_on_hero('hero_' + @active_unit_id)
    @bind_attack_handlers()

  init_ul: (ul) ->
    @map.remove_units()
    @units = []
    @my_units = []
    for pos, unit_hash of ul
      unit_obj = UnitFactory(unit_hash, @user_id)
      if unit_obj
        @units.push(unit_obj)
        @map.append(unit_obj)
        if unit_hash['@user'] == @user_id
          @my_units.push(unit_obj)
          @controls.unit_info(unit_hash)
    @bind_attack_handlers()
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

  bind_attack_handlers: () ->
    cell = $('#hero_' + @active_unit_id).parent()
    if cell.length == 1
      pos = cell.attr('id').replace('cell_', '').split('_')
      for dx in [-1..1]
        for dy in [-1..1]
          if dx || dy
            x = parseInt(pos[0]) + dx
            y = parseInt(pos[1]) + dy
            @bind_attack_handler(x, y)
        
  bind_attack_handler: (x, y) ->
    adj_cell = $('#cell_' + x + '_' + y)
    unit = adj_cell.children('div').get(0)
    if unit
      if $(unit).hasClass('player-hero')
        $(unit).css('cursor', 'pointer').one('click', () =>
          @controls.set_active_unit($(unit).data('id'))
        )
      else
        $(unit).css('cursor', 'crosshair').one('click', () =>
          if !@attacking
            @attacking = true
            @ws.attack(@user_id, @active_unit_id, {x: x, y: y})
        )

  log: (data) ->
    div = document.createElement('div')
    div.innerHTML = data
    $(div).prependTo('#log')

window.App = new Application
