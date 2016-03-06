class WS
  constructor: (app) ->
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
      switch data.data_type
        when 'init_map'
          app.map = new Map data.cell_dim_in_px, data.block_dim_in_px, data.block_dim_in_cells, data.map_dim_in_blocks
          app.init_ul data.ul
        when 'ul' then app.init_ul(data.ul)
        when 'dmg' then app.map.dmg(data.x, data.y, data.dmg, data.ca_dmg)
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

  move: (token, params) ->
    @socket.send(
      JSON.stringify({
          token: token,
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

  attack: (token, params) ->
    @socket.send(
      JSON.stringify({
          token: token,
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

window.WS = WS
