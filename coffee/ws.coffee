class WS
  constructor: (app) ->
    # there are some race conditions when 'ul' will came before 'init_map'
    @initialized = false
    ws = new WebSocket 'ws://' + location.hostname + ':9293'
    @socket = ws;
    $(window).on('beforeunload', () ->
        ws.send(JSON.stringify({token: app.user_id, op: 'close'}))
        ws.close()
    )
    ws.onopen = () ->
      ws.send(JSON.stringify({token: app.user_id, op: 'init'}))
    
    ws.onmessage = (e) ->
      data = JSON.parse(e.data)
      console.log(data)
      if app.initialized || data.data_type == 'init_map'
        switch data.data_type
          when 'init_map'
            app.map = new Map data.cell_dim_in_px, data.block_dim_in_px, data.block_dim_in_cells, data.map_dim_in_blocks
            app.init_ul data.ul
            app.set_active_unit data.active_unit
            app.initialized = true
          when 'ul'
            app.init_ul data.ul
            if data.active_unit
              app.set_active_unit data.active_unit
            else if data.action == 'move'
              app.center_on_active()
          when 'dmg'
            app.map.dmg(data.x, data.y, data.dmg, data.ca_dmg, data.a_id)
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

  move: (token, unit_id, params) ->
    @socket.send(
      JSON.stringify({
          token: token,
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

  attack: (token, unit_id, params) ->
    @socket.send(
      JSON.stringify({
          token: token,
          unit_id: unit_id,
          op: 'attack',
          params: params
      })
    )

  revive: (token) ->
    @socket.send(
      JSON.stringify({
        token: token,
        op: 'revive'
      })
    )

  new_hero: (token) ->
    @socket.send(
      JSON.stringify({
        token: token,
        op: 'new_hero'
      })
    )


window.WS = WS
