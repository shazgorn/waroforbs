class WS
  constructor: (app) ->
    # there are some race conditions when 'ul' will came before 'init_map'
    @initialized = false
    @token = localStorage.getItem('token')
    unless @token then location.pathname = '/'
    @socket = new WebSocket 'ws://' + location.hostname + ':' + ws_port
    $(window).on('beforeunload', () =>
      @socket.send(JSON.stringify({token: @token, op: 'close'}))
      @socket.close()
    )

    @socket.onopen = () =>
      @socket.send(JSON.stringify({token: @token, op: 'init_map'}))

    @socket.onerror = (e) =>
      console.error(e)

    @socket.onclose = (e) =>
      App.log({message: 'Connection to server has been closed. Please reload page.', type: 'info', time: 'interface'})
      console.info(e)

    @socket.onmessage = (e) ->
      start_ts = new Date();
      data = JSON.parse(e.data)
      console.info('data:', data)
      console.error('no data_type') unless data.data_type
      if app.initialized || data.data_type == 'init_map'
        switch data.data_type
          when 'init_map'
            # App init set properties
            app.cells = data.cells
            app.map = new Map data.cell_dim_in_px, data.block_dim_in_px, data.block_dim_in_cells, data.map_dim_in_blocks, data.cells
            app.active_unit_id = data.active_unit_id
            app.user_id = data.user_id
            app.building_states = data.building_states
            app.TOWN_RADIUS = data.TOWN_RADIUS
            app.MAX_CELL_IDX = data.MAX_CELL_IDX

            # App init function calls
            app.init_units data.units
            app.center_on_active()
            app.set_active_unit_directly data.active_unit_id
            app.init_user_controls data.actions

            for l in data.logs
              app.log(l)

            # App init finished
            app.initialized = true
          when 'units'
            if data.op == "attack"
              if data.defender
                app.map.dmg(data.d_dmg.wounds, data.d_dmg.kills, data.a_dmg.wounds, data.a_dmg.kills, data.d_id, data.a_id, 789, 123)
              else
                app.map.dmg(data.a_dmg.wounds, data.a_dmg.kills, data.d_dmg.wounds, data.d_dmg.kills, data.a_id, data.d_id, 123, 789)
            app.init_units data.units
            if data.active_unit_id && data.op in ['move', 'new_random_infantry']
              app.set_active_unit data.active_unit_id
            app.update_user_controls data.actions
            app.refresh_modals()
            app.attacking = false
          when 'error'
            switch data.error
              when 'wrong_token' then location.pathname = '/'
        if data.log
          app.log(data.log)
        app.unlock_controls()
        console.info('js execution time:', new Date() - start_ts, 'ms')

  move: (unit_id, params) ->
    @socket.send(
      JSON.stringify({
          token: @token,
          unit_id: unit_id,
          op: 'move',
          params: params
      })
    )

  attack: (unit_id, params) ->
    @socket.send(
      JSON.stringify({
          token: @token,
          unit_id: unit_id,
          op: 'attack',
          params: params
      })
    )

  new_random_infantry: () ->
    @socket.send(
      JSON.stringify({
        token: @token,
        op: 'new_random_infantry'
      })
    )

  new_town: (unit_id) ->
    @socket.send(
      JSON.stringify({
        token: @token,
        unit_id: unit_id,
        op: 'new_town'
      })
    )

  dismiss: (unit_id) ->
    @socket.send(
      JSON.stringify({
        token: @token,
        unit_id: unit_id,
        op: 'dismiss'
      })
    )

  build: (id) ->
    @socket.send(
      JSON.stringify({
        token: @token,
        building: id,
        op: 'build'
      })
    )

  create_default_company: () ->
    @socket.send(
      JSON.stringify({
        token: @token,
        op: 'create_default_company'
      })
    )

  create_company: () ->
    @socket.send(
      JSON.stringify({
        token: @token,
        op: 'create_company'
      })
    )

  add_squad_to_company: (company_id, town_id) ->
    @socket.send(
      JSON.stringify({
        token: @token,
        op: 'add_squad_to_company',
        company_id: company_id,
        town_id: town_id
      })
    )

  set_free_worker_to_xy: (town_id, x, y) ->
    @socket.send(
      JSON.stringify({
        token: @token,
        op: 'set_free_worker_to_xy',
        town_id: town_id,
        x: x,
        y: y
      })
    )

  free_worker: (town_id, x, y) ->
    @socket.send(
      JSON.stringify({
        token: @token,
        op: 'free_worker',
        town_id: town_id,
        x: x,
        y: y
      })
    )

  restart: () ->
    @socket.send(
      JSON.stringify({
        token: @token,
        op: 'restart'
      })
    )

  units: () ->
    @socket.send(
      JSON.stringify({
        token: @token,
        op: 'units'
      })
    )

window.WS = WS
