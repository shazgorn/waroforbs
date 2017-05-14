class Controls
  constructor: (app) ->
    _controls = this

    @user_actions =
      'action_new_hero': {
        name: 'New hero',
        callback: () ->
          App.new_hero()
      },
      'action_new_town': {
        name: 'New town',
        callback: () ->
          App.new_town()
      }

    controls = {
      7: {arr: '&#8598;', x: -1, y: -1},
      8: {arr: '&#8593;', x:  0, y: -1},
      9: {arr: '&#8599;', x:  1, y: -1},
      4: {arr: '&#8592;', x: -1, y:  0},
      5: {arr: '&#8635;', x:  0, y:  0},
      6: {arr: '&#8594;', x:  1, y:  0},
      1: {arr: '&#8601;', x: -1, y:  1},
      2: {arr: '&#8595;', x:  0, y:  1},
      3: {arr: '&#8600;', x:  1, y:  1},
    }
    controls_order = [7, 8, 9, 4, 5, 6, 1, 2, 3]
    for bn in controls_order
      control = controls[bn]
      control_button = document.createElement('button')
      $(control_button).html(control.arr)
      $(control_button).attr('id', 'control_' + bn)
      control_button.dataset.dx = control.x
      control_button.dataset.dy = control.y
      $('#controls-arrows').append(control_button)
    @lock_controls()
    $('#controls-arrows button').click(() ->
      app.lock_controls()
      app.move({
        dx: parseInt(this.dataset.dx),
        dy: parseInt(this.dataset.dy)
      })
    )

  lock_controls: () ->
    $('#controls-arrows button').prop('disabled', 'disabled')

  unlock_controls: () ->
    $('#controls-arrows button').prop('disabled', '')

  set_active_unit: (id) ->
    $('.active-unit-info').removeClass('active-unit-info')
    $("#unit-info-#{id}").addClass('active-unit-info')
    $(".active-player-unit").removeClass('active-player-unit')
    $("#unit-#{id}").addClass('active-player-unit')

  init_user_controls: (actions) ->
    for id, val of @user_actions
      $a = $("#user-controls ##{id}")
      if $.inArray(id, actions) == -1
        $a.remove()
      else
        if $a.length == 0
          $(document.createElement('button'))
          .html(val.name)
          .attr('id', id)
          .data('id', id)
          .appendTo('#user-controls')
          .click(val.callback)


window.Controls = Controls
