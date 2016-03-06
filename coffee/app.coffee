class Application
  constructor: () ->
    @user_id = localStorage.getItem('user_id')
    unless @user_id then location.pathname = '/'
    @units = []
    @controls = new Controls this
    @ws = new WS this

  move: (params) ->
    @ws.move(@user_id, params)

  lock_controls: () ->
    @controls.lock_controls()

  unlock_controls: () ->
    @controls.unlock_controls()

  spawn_bot: (id) ->
    @ws.spawn_bot()

  revive: () ->
    @ws.revive(@user_id)

  new_hero: () ->
    @ws.new_hero(@user_id)

  init_ul: (ul) ->
    @map.remove_units()
    @units = [];
    for pos, unit of ul
      unit = UnitFactory(unit, @user_id)
      if unit
        @units.push(unit)
        @map.append(unit)
    cell = $('#the_hero').parent()
    if cell.length == 1
        pos = cell.attr('id').replace('cell_', '').split('_')
        app = this
        for dx in [-1..1]
          for dy in [-1..1]
            if dx || dy
              x = parseInt(pos[0]) + dx
              y = parseInt(pos[1]) + dy
              this.bind_attack_handler(app, x, y)
        
  bind_attack_handler: (app, x, y) ->
    adj_cell = $('#cell_' + x + '_' + y)
    unit = adj_cell.children('div').get(0)
    if unit
      $(unit).css('cursor', 'crosshair').click(() ->
          app.ws.attack(app.user_id, {x: x, y: y})
      )

new Application
