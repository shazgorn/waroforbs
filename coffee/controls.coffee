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

    $('#restart').click(() ->
      app.restart()
    )

    $('#close-modal').click(() ->
      $(this).parent().parent().hide()
    )

  lock_controls: () ->
    $('#controls_arrows button').prop('disabled', 'disabled')

  unlock_controls: () ->
    $('#controls_arrows button:not(#control_5)').prop('disabled', '')

  unit_info: (unit) ->
    id = unit['@id']
    id_attr = 'unit-info-' + id
    id_sel = '#' + id_attr
    if $(id_sel).length == 0
      info = $('.unit-info-template')
        .clone()
        .prependTo('#right-col')
        .removeClass('unit-info-template')
        .attr('id', id_attr)
        .data('id', id)
        .hover(
          () ->
            $("#unit-#{id}").addClass('player-unit-hover')
          ,
          () ->
            $("#unit-#{id}").removeClass('player-unit-hover')
        )
      if App.active_unit_id == id
        info.addClass('active-unit-info')
    
    $(id_sel).data('id', id)
    _this = this
    $(id_sel).off('click').on('click', () ->
      App.set_active_unit($(this).data('id'))
    )
    switch unit['@type']
      when 'PlayerHero' then $(id_sel + ' .unit-name-info').html('H')
      when 'Town' then $(id_sel + ' .unit-name-info').html('T')
    $(id_sel + ' .unit-id-info').html(unit['@id'])
    $(id_sel + ' .player-name-info').html(unit['@user_name'])
    $(id_sel + ' .hp-info').html(unit['@hp'])
    $(id_sel + ' .x-info').html(unit['@x'])
    $(id_sel + ' .y-info').html(unit['@y'])

  set_active_unit: (id) ->
    $('.active-unit-info').removeClass('active-unit-info')
    $("#unit-info-#{id}").addClass('active-unit-info')
    $(".active-player-unit").removeClass('active-player-unit')
    $("#unit-#{id}").addClass('active-player-unit')

window.Controls = Controls
