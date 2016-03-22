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

  set_active_unit: (unit_id) ->
    @active_unit_id = unit_id
    @map.center_on_hero('hero_' + unit_id)

  center_on_active: () ->
    @map.center_on_hero('hero_' + @active_unit_id)

  init_ul: (ul) ->
    @map.remove_units()
    @units = []
    @my_units = []
    for pos, unit_hash of ul
      unit_obj = UnitFactory(unit_hash, @user_id)
      if unit_obj
        @units.push(unit_obj)
        @map.append(unit_obj)
        # console.log(unit_hash, @user_id)
        if unit_hash['@user'] == @user_id
          @my_units.push(unit_obj)
          @controls.unit_info(unit_hash)
    cell = $('#hero_' + @active_unit_id).parent()
    if cell.length == 1
      pos = cell.attr('id').replace('cell_', '').split('_')
      app = this
      for dx in [-1..1]
        for dy in [-1..1]
          if dx || dy
            x = parseInt(pos[0]) + dx
            y = parseInt(pos[1]) + dy
            @bind_attack_handler(app, x, y)
    # delete dead units
    # console.log('my units:', @my_units)
    if @my_units.length == 0
      # console.log('no units')
      @lock_controls()
    my_units_ids = $.map(@my_units, (unit) ->
      unit.object_id
    )
    # console.log(my_units_ids)
    # console.log($('.unit-info'))
    # console.log($('.unit-info:not(.unit-info-template)'))
    # return
    $('.unit-info:not(.unit-info-template)').each((i, el) ->
      # console.log(el, $(el).data('id'), my_units_ids)
      if $.inArray($(el).data('id'), my_units_ids) == -1
        # console.log('not in array')
        $(el).remove()
    )
    null
        
  bind_attack_handler: (app, x, y) ->
    adj_cell = $('#cell_' + x + '_' + y)
    unit = adj_cell.children('div').get(0)
    if unit
      $(unit).css('cursor', 'crosshair').click(() ->
          app.ws.attack(app.user_id, app.active_unit_id, {x: x, y: y})
      )

window.App = new Application
