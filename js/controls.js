(function() {
  var Controls;

  Controls = (function() {
    function Controls(app) {
      var bn, control, control_button, controls, controls_order, i, len;
      controls = {
        7: {
          arr: '&#8598;',
          x: -1,
          y: -1
        },
        8: {
          arr: '&#8593;',
          x: 0,
          y: -1
        },
        9: {
          arr: '&#8599;',
          x: 1,
          y: -1
        },
        4: {
          arr: '&#8592;',
          x: -1,
          y: 0
        },
        5: {
          arr: '&#8597;',
          x: 0,
          y: 0
        },
        6: {
          arr: '&#8594;',
          x: 1,
          y: 0
        },
        1: {
          arr: '&#8601;',
          x: -1,
          y: 1
        },
        2: {
          arr: '&#8595;',
          x: 0,
          y: 1
        },
        3: {
          arr: '&#8600;',
          x: 1,
          y: 1
        }
      };
      controls_order = [7, 8, 9, 4, 5, 6, 1, 2, 3];
      for (i = 0, len = controls_order.length; i < len; i++) {
        bn = controls_order[i];
        control = controls[bn];
        control_button = document.createElement('button');
        $(control_button).html(control.arr);
        $(control_button).attr('id', 'control_' + bn);
        control_button.dataset.dx = control.x;
        control_button.dataset.dy = control.y;
        $('#controls_arrows').append(control_button);
      }
      this.lock_controls();
      $('#controls_arrows button').click(function() {
        app.lock_controls();
        return app.move({
          dx: parseInt(this.dataset.dx),
          dy: parseInt(this.dataset.dy)
        });
      });
      $('#spawn-bot').click(function() {
        return app.spawn_bot();
      });
      $('#revive').click(function() {
        return app.revive();
      });
    }

    Controls.prototype.lock_controls = function() {
      return $('#controls_arrows button').prop('disabled', 'disabled');
    };

    Controls.prototype.unlock_controls = function() {
      return $('#controls_arrows button:not(#control_5)').prop('disabled', '');
    };

    return Controls;

  })();

  window.Controls = Controls;

}).call(this);
