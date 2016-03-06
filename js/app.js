(function() {
  var Application;

  Application = (function() {
    function Application() {
      this.user_id = localStorage.getItem('user_id');
      if (!this.user_id) {
        location.pathname = '/';
      }
      this.units = [];
      this.controls = new Controls(this);
      this.ws = new WS(this);
    }

    Application.prototype.move = function(params) {
      return this.ws.move(this.user_id, params);
    };

    Application.prototype.lock_controls = function() {
      return this.controls.lock_controls();
    };

    Application.prototype.unlock_controls = function() {
      return this.controls.unlock_controls();
    };

    Application.prototype.spawn_bot = function(id) {
      return this.ws.spawn_bot();
    };

    Application.prototype.revive = function() {
      return this.ws.revive();
    };

    Application.prototype.init_ul = function(ul) {
      var app, cell, dx, dy, i, pos, results, unit, x, y;
      this.map.remove_units();
      this.units = [];
      for (pos in ul) {
        unit = ul[pos];
        unit = UnitFactory(unit, this.user_id);
        if (unit) {
          this.units.push(unit);
          this.map.append(unit);
        }
      }
      cell = $('#the_hero').parent();
      if (cell.length === 1) {
        pos = cell.attr('id').replace('cell_', '').split('_');
        app = this;
        results = [];
        for (dx = i = -1; i <= 1; dx = ++i) {
          results.push((function() {
            var j, results1;
            results1 = [];
            for (dy = j = -1; j <= 1; dy = ++j) {
              if (dx || dy) {
                x = parseInt(pos[0]) + dx;
                y = parseInt(pos[1]) + dy;
                results1.push(this.bind_attack_handler(app, x, y));
              } else {
                results1.push(void 0);
              }
            }
            return results1;
          }).call(this));
        }
        return results;
      }
    };

    Application.prototype.bind_attack_handler = function(app, x, y) {
      var adj_cell, unit;
      adj_cell = $('#cell_' + x + '_' + y);
      unit = adj_cell.children('div').get(0);
      if (unit) {
        return $(unit).css('cursor', 'crosshair').click(function() {
          return app.ws.attack(app.user_id, {
            x: x,
            y: y
          });
        });
      }
    };

    return Application;

  })();

  new Application;

}).call(this);
