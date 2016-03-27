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
    @lock_controls();
    $('#controls_arrows button').click(() ->
        app.lock_controls()
        app.move(
            {
                dx: parseInt(this.dataset.dx),
                dy: parseInt(this.dataset.dy)
            }
        )
    )
    $('#spawn-bot').click(() ->
        app.spawn_bot()
    );

    $('#revive').click(() ->
        app.revive()
    );

    $('#new-hero').click(() ->
        app.new_hero()
    );

    $('#new-town').click(() ->
      app.new_town()
    )

  lock_controls: () ->
    $('#controls_arrows button').prop('disabled', 'disabled')

  unlock_controls: () ->
    $('#controls_arrows button:not(#control_5)').prop('disabled', '')

  unit_info: (unit) ->
    id = '#unit-info-' + unit['@id']
    if $(id).length == 0
      info = $('.unit-info-template')
        .clone()
        .prependTo('#right-col')
        .attr('id', 'unit-info-' + unit['@id'])
        .data('id', unit['@id'])
        .removeClass('unit-info-template')
        .hover(
          () ->
            $("#hero_#{$(this).data('id')}").addClass('player-hero-hover')
          ,
          () ->
            $("#hero_#{$(this).data('id')}").removeClass('player-hero-hover')
        )
      console.log(App, App.active_unit_id, unit['@id'])
      if App.active_unit_id == unit['@id']
        info.addClass('active-unit-info')
        console.log(info)
    
    $(id).data('unit-id', unit['@id']).data('id', unit['@id'])
    $(id).click(() ->
      App.set_active_unit(unit['@id'])
      $('.active-unit-info').removeClass('active-unit-info')
      $(this).addClass('active-unit-info')
      App.unlock_controls()
    )
    $(id + ' .unit-id-info').html(unit['@id'])
    $(id + ' .player-name-info').html(unit['@user'])
    $(id + ' .hp-info').html(unit['@hp'])
    $(id + ' .x-info').html(unit['@x'])
    $(id + ' .y-info').html(unit['@y'])

window.Controls = Controls
