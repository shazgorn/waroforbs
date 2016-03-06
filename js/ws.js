(function() {
  var WS;

  WS = (function() {
    function WS(app) {
      var a, ws;
      a = 123;
      ws = new WebSocket('ws://' + location.hostname + ':9293');
      this.socket = ws;
      $(window).on('beforeunload', function() {
        ws.send(JSON.stringify({
          token: app.user_id,
          op: 'close'
        }));
        return ws.close();
      });
      ws.onopen = function() {
        return ws.send(JSON.stringify({
          token: app.user_id,
          op: 'init'
        }));
      };
      ws.onmessage = function(e) {
        var colCount, data, h, i, j, len, len1, ref, ref1, row, rowCount, table, user;
        data = JSON.parse(e.data);
        console.log(data);
        switch (data.data_type) {
          case 'init_map':
            app.map = new Map(data.cell_dim_in_px, data.block_dim_in_px, data.block_dim_in_cells, data.map_dim_in_blocks);
            app.init_ul(data.ul);
            break;
          case 'ul':
            app.init_ul(data.ul);
            break;
          case 'dmg':
            app.map.dmg(data.x, data.y, data.dmg, data.ca_dmg);
            break;
          case 'scores':
            table = $('#scores table').get(0);
            rowCount = 0;
            colCount = 0;
            $('#scores table tr').remove();
            row = table.insertRow(rowCount++);
            ref = ['#', 'login', 'score'];
            for (i = 0, len = ref.length; i < len; i++) {
              h = ref[i];
              $(row).append($(document.createElement('th')).html(h));
            }
            ref1 = data.scores;
            for (j = 0, len1 = ref1.length; j < len1; j++) {
              user = ref1[j];
              row = table.insertRow(rowCount++);
              colCount = 0;
              row.insertCell(colCount++).innerHTML = '';
              row.insertCell(colCount++).innerHTML = user.login;
              row.insertCell(colCount++).innerHTML = user.score;
            }
            break;
          case 'move':
            $('#log').prepend($(document.createElement('div')).html(data.log));
            break;
          case 'error':
            switch (data.error) {
              case 'wrong_token':
                location.pathname = '/';
            }
        }
        return app.unlock_controls();
      };
    }

    WS.prototype.move = function(token, params) {
      return this.socket.send(JSON.stringify({
        token: token,
        op: 'move',
        params: params
      }));
    };

    WS.prototype.spawn_bot = function() {
      return this.socket.send(JSON.stringify({
        op: 'spawn_bot'
      }));
    };

    WS.prototype.attack = function(token, params) {
      return this.socket.send(JSON.stringify({
        token: token,
        op: 'attack',
        params: params
      }));
    };

    WS.prototype.revive = function(token) {
      return this.socket.send(JSON.stringify({
        token: token,
        op: 'revive'
      }));
    };

    return WS;

  })();

  window.WS = WS;

}).call(this);
