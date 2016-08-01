class Controls
  constructor: (app) ->
    @open_building_id = null
    @user_actions =
      'new_hero': {
        name: 'New hero',
        callback: () ->
          App.new_hero()
      },
      'new_town': {
        name: 'New town',
        callback: () ->
          App.new_town()
      }
    @town_actions =
      'create_default_company': {
        name: 'Create company',
        callback: () ->
          app.create_default_company()
      }
    @buildings =
      'banner_shop': {
        name: 'Banner Shop',
        callback: () ->
          # clean up
          $('.banner-card').remove()
          $('.modal.building button').remove()

          # fill up
          for banner in App.banners
            b = $(document.createElement('div'))
              .addClass('banner-card')
              .html("Banner ##{banner['@id']} <br> hp:
  #{banner['@mod_max_hp']} <br>ap: #{banner['@mod_max_ap']} <br>unit_id: #{banner['@unit_id']}")
              .appendTo('.modal.building .modal-building-inner')

          # actions
          $(document.createElement('button'))
            .html('Create default banner')
            .appendTo('.modal.building .modal-building-actions')
            .click(() ->
              App.create_default_banner()
            )
      },
      'barracs': {
        name: 'Barracs',
        callback: () ->
          # clean up
          $('.banner-card').remove()
          $('.modal-body .modal-building-inner *').remove()
          $('.modal-body .modal-building-actions *').remove()
          $('.modal.building button').remove()

          #fill up
          for banner in App.banners
            if banner['@unit_id'] == null
              $(document.createElement('div'))
                .data('id', banner['@id'])
                .addClass('banner-card')
                .html("Banner ##{banner['@id']} <br> hp: #{banner['@mod_max_hp']} <br>ap: #{banner['@mod_max_ap']} <br>unit_id: #{banner['@unit_id']}")
                .appendTo('.modal.building .modal-building-inner')
                .click(() ->
                  App.create_company_from_banner($(this).data('id'))
                )

          # actions
          $(document.createElement('button'))
            .html('Create company')
            .appendTo('.modal.building .modal-building-actions')
            .click(() ->
              App.create_default_company()
            )
      }
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

    $('.close-modal').click(() ->
      @open_building_id = null
      $('.modal').hide()
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
      when 'PlayerCompany' then $(id_sel + ' .unit-name-info').html('H')
      when 'Town' then $(id_sel + ' .unit-name-info').html('T')
    $(id_sel + ' .unit-id-info').html(unit['@id'])
    $(id_sel + ' .player-name-info').html(unit['@user_name'])
    $(id_sel + ' .hp-info').html(unit['@hp'])
    $(id_sel + ' .xy-info').html(unit['@x'] + ',' + unit['@y'])
    # $(id_sel + ' .y-info').html(unit['@y'])
    $(id_sel + ' .ap-info').html(unit['@ap'])

  set_active_unit: (id) ->
    $('.active-unit-info').removeClass('active-unit-info')
    $("#unit-info-#{id}").addClass('active-unit-info')
    $(".active-player-unit").removeClass('active-player-unit')
    $("#unit-#{id}").addClass('active-player-unit')

  # add building`s blocks and build buttons
  init_town_buildings: (buildings) ->
    $('.open-building-screen').remove()
    _this = this
    for id, building of buildings
      $b = $("##{id}")
      open_building_sel = "open-screen-#{id}"
      # building container with link, time to build and build button
      b = $(document.createElement('div'))
        .attr('id', id)
        .addClass('open-building-screen')
        .appendTo('.modal.town .buildings')

      $open_building = $(document.createElement('a'))
        .html(building['@name'] + ' (' + building['@status'] + ')')
        .attr('id', open_building_sel)
        .attr('href', '#')
        .data('id', id)

      switch building['@status']
        when App.building_states['BUILDING_STATE_CAN_BE_BUILT']
          # if not built then 'gray' color
          $open_building
            .addClass('builging_not_built')
            .click((e) ->
              e.preventDefault()
            )
        when App.building_states['BUILDING_STATE_IN_PROGRESS']
          # if built then 'yellow' color
          $open_building.click((e) ->
            e.preventDefault()
          )
        when App.building_states['BUILDING_STATE_BUILT']
          # if built then 'black' color
          $open_building
            .addClass('builging_built')
            .click(() ->
              _this.open_building(this)
              $('.back-to-town').click(() ->
                $('.modal.building').hide()
                $('.modal.town').show()
              )
            )

      b.html($open_building)

      # build button
      if building['@status'] == 1
        $("##{id} button").remove()
      else if building['@status'] == 0 && $("##{id}").length == 1 && $("##{id} button").length == 0
        button = $(document.createElement('button'))
          .html('Build')
          .data('id', id)
          .appendTo("##{id}")
          .click(() ->
            App.build(this)
          )

  init_town_controls: (actions) ->
    for action in actions
      action_val = @town_actions[action]
      $a = $(".town .actions ##{action}")
      if $a.length == 0
        b = $(document.createElement('button'))
          .html(action_val.name)
          .attr('id', action)
          .data('id', action)
          .appendTo('.town .actions')
          .click(() ->
            action_val.callback this
          )
    # delete old actions

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

  fill_building_modal: (id) ->
    @buildings[id].callback()

  open_building: (button) ->
    $('.modal').hide()
    id = $(button).data('id')
    $('.modal.building').show()
    $('.modal.building .modal-title').html(@buildings[id].name)
    @fill_building_modal(id)
    @open_building_id = id

window.Controls = Controls
