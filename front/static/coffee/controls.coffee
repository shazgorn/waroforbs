class Controls
  constructor: (app) ->
    _controls = this

    @user_actions = []

    @actions = {
      'settle_town_action': {
        callback: () ->
          App.settle_town()
      }
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

  update_action: (key, action) ->
    @actions[key].label = action['@label']
    $a = $("#user-controls ##{key}")
    if action['@on'] && $a.length == 0
      $(document.createElement('button'))
        .html(action['@label'])
        .attr('id', key)
        .data('id', key)
        .appendTo('#user-controls')
        .click(@actions[key].callback)
    else if !action['@on'] && $a.length
      $a.remove()

  update_actions: (actions) ->
    for key, action of actions
      @update_action key, action

  init_user_controls: (actions) ->
    for key, action of actions
      @actions[key].label = action['@label']
    @update_actions actions

  update_user_controls: (actions) ->
    @update_actions actions

window.Controls = Controls
