class WS
  constructor: (app) ->
    # there are some race conditions when 'ul' will came before 'init_map'
    @initialized = false
    @token = localStorage.getItem('token')
    console.log(@token)
    unless @token then location.pathname = '/'
    @socket = new WebSocket 'ws://' + location.hostname + ':9293'
    $(window).on('beforeunload', () =>
      @socket.send(JSON.stringify({token: @token, op: 'close'}))
      @socket.close()
    )

    @socket.onopen = () =>
      @socket.send(JSON.stringify({token: @token, op: 'init'}))
    
    @socket.onmessage = (e) ->
      data = JSON.parse(e.data)
      console.log(data)
      if app.initialized || data.data_type == 'init_map'
        switch data.data_type
          when 'init_map'
            app.map = new Map data.cell_dim_in_px, data.block_dim_in_px, data.block_dim_in_cells, data.map_dim_in_blocks
            app.active_unit_id = data.active_unit_id
            app.user_id = data.user_id
            app.init_units data.units
            app.center_on_active()
            app.controls.set_active_unit(data.active_unit_id)
            app.initialized = true
          when 'units'
            app.init_units data.units
            if data.active_unit
              app.set_active_unit data.active_unit_id
            else if data.action == 'move'
              app.center_on_active()
          when 'dmg'
            app.map.dmg(data.dmg, data.ca_dmg, data.a_id, data.d_id)
            app.log('damage dealt ' + data.dmg)
            app.log('damage taken ' + data.ca_dmg)
            if data.a_dead
              app.log('Your hero has been killed')
            app.attacking = false
          when 'scores'
            table = $('#scores table').get(0)
            rowCount = 0
            colCount = 0
            $('#scores table tr').remove()
            row = table.insertRow(rowCount++)
            for h in ['#', 'login', 'score']
              $(row).append($(document.createElement('th')).html(h))
            for user in data.scores
                row = table.insertRow(rowCount++)
                colCount = 0
                row.insertCell(colCount++).innerHTML = ''
                row.insertCell(colCount++).innerHTML = user.login
                row.insertCell(colCount++).innerHTML = user.score
          when 'move'
             $('#log').prepend($(document.createElement('div')).html(data.log))
          when 'error'
            switch data.error
              when 'wrong_token' then location.pathname = '/'
        app.unlock_controls()

  move: (unit_id, params) ->
    @socket.send(
      JSON.stringify({
          token: @token,
          unit_id: unit_id,
          op: 'move',
          params: params
      })
    )

  spawn_bot: () ->
    @socket.send(
      JSON.stringify({
          op: 'spawn_bot'
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

  revive: () ->
    @socket.send(
      JSON.stringify({
        token: @token,
        op: 'revive'
      })
    )

  new_hero: () ->
    @socket.send(
      JSON.stringify({
        token: @token,
        op: 'new_hero'
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

  restart: () ->
    @socket.send(
      JSON.stringify({
        token: @token,
        op: 'restart'
      })
    )


window.WS = WS
