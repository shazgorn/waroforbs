class Controls
  constructor: (app) ->
    controls = 
      7: {arr: '&#8598;', x: -1, y: -1},
      8: {arr: '&#8593;', x:  0, y: -1},
      9: {arr: '&#8599;', x:  1, y: -1},
      4: {arr: '&#8592;', x: -1, y:  0},
      5: {arr: '&#8597;', x:  0, y:  0},
      6: {arr: '&#8594;', x:  1, y:  0},
      1: {arr: '&#8601;', x: -1, y:  1},
      2: {arr: '&#8595;', x:  0, y:  1},
      3: {arr: '&#8600;', x:  1, y:  1},
    controls_order = [7, 8, 9, 4, 5, 6, 1, 2, 3]
    for bn in controls_order
        control = controls[bn];
        control_button = document.createElement('button');
        $(control_button).html(control.arr);
        $(control_button).attr('id', 'control_' + bn);
        control_button.dataset.dx = control.x;
        control_button.dataset.dy = control.y;
        $('#controls_arrows').append(control_button);
    this.lock_controls();
    $('#controls_arrows button').click(() ->
        app.lock_controls()
        app.move(
            {
                dx: parseInt(this.dataset.dx),
                dy: parseInt(this.dataset.dy)
            }
        )
    )
    $(document.createElement('button'))
        .html('Spawn bot')
        .appendTo('#controls')
        .click(() ->
            app.spawn_bot()
        );

  lock_controls: () ->
    $('#controls_arrows button').prop('disabled', 'disabled')

  unlock_controls: () ->
    $('#controls_arrows button:not(#control_5)').prop('disabled', '')

window.Controls = Controls