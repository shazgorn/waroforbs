class Controls
  constructor: (app) ->
    _controls = this
    @open_building_id = null
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
          $('.modal-body .modal-building-inner *').remove()
          $('.modal-body .modal-building-actions-inner *').remove()

          # fill up
          for banner in App.banners
            b = _controls.banner_card(banner, 'Banner')
            if !banner['@unit_id']
              $(document.createElement('button'))
                .data('id', banner['@id'])
                .html('Delete')
                .appendTo(b)
                .click(() ->
                  App.delete_banner($(this).data('id'))
                )

          # actions
          $(document.createElement('button'))
            .html('Create random banner 10 gold')
            .appendTo('.modal.building .modal-building-actions-inner')
            .click(() ->
              App.create_random_banner()
            )
      },
      'barracs': {
        name: 'Barracs',
        callback: () ->
          # clean up
          $('.banner-card').remove()
          $('.modal-body .modal-building-inner *').remove()
          $('.modal-body .modal-building-actions-inner *').remove()

          #fill up
          for banner in App.banners
            if banner['@unit_id'] == null
              b = _controls.banner_card(banner, 'Create company')
              b
                .addClass('pointer')
                .click(() ->
                  App.create_company_from_banner($(this).data('id'))
                )

          # actions
          $(document.createElement('button'))
            .html('Create company')
            .appendTo('.modal.building .modal-building-actions-inner')
            .click(() ->
              App.create_default_company()
            )

          $(document.createElement('div'))
            .addClass('modal-building-fill')
            .appendTo('.modal.building .modal-building-inner')

          for company_id in App.units[App.last_town].adj_companies
            company = App.my_units[company_id]
            card = $(document.createElement('div'))
              .addClass('company-card')
              .addClass('pointer')
              .data('id', company_id)
              .attr('title', 'Add squad')
              .html("Company ##{company_id} <br> x,y: #{company.x},#{company.y}<br> dmg: #{company.dmg} <br> def: #{company.def} <br> hp:
  #{company.hp} <br>ap: #{company.ap} <br> squads: #{company.squads}")
              .appendTo('.modal.building .modal-building-fill')
              .click(() ->
                App.add_squad_to_company($(this).data('id'))
              )
      }
    controls = 
      7: {arr: '&#8598;', x: -1, y: -1},
      8: {arr: '&#8593;', x:  0, y: -1},
      9: {arr: '&#8599;', x:  1, y: -1},
      4: {arr: '&#8592;', x: -1, y:  0},
      5: {arr: '&#8635;', x:  0, y:  0},
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

  banner_card: (banner, title) ->
    $(document.createElement('div'))
      .addClass('banner-card')
      .data('id', banner['@id'])
      .attr('title', title)
      .html("Banner ##{banner['@id']} <br> dmg: #{banner['@mod_dmg']} <br> def: #{banner['@mod_def']} <br> hp: #{banner['@mod_max_hp']} <br>ap: #{banner['@mod_max_ap']} <br>unit_id: #{banner['@unit_id']}")
      .appendTo('.modal.building .modal-building-inner')

  lock_controls: () ->
    $('#controls_arrows button').prop('disabled', 'disabled')

  unlock_controls: () ->
    $('#controls_arrows button').prop('disabled', '')

  unit_info: (unit) ->
    id = unit['@id']
    id_attr = 'unit-info-' + id
    id_sel = '#' + id_attr
    if $(id_sel).length == 0
      info = $('.unit-info-template')
        .clone()
        .appendTo('#unit-info-list')
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
      when 'company'
        $(id_sel + ' .unit-name-info').html('C')
        $(id_sel + ' .unit-squads-info').html(unit['@squads'])
      when 'town'
        $(id_sel + ' .unit-name-info').html('T')
        #$(id_sel + ' .unit-ap-info').remove()
        #$(id_sel + ' .unit-squads-info').remove()
    $(id_sel + ' .unit-id-info').html(unit['@id'])
    #$(id_sel + ' .player-name-info').html(unit['@user_name'])
    $(id_sel + ' .unit-hp-info').html(unit['@hp'] + '/' + unit['@max_hp'])
    $(id_sel + ' .unit-xy-info').html('{' + unit['@x'] + ',' + unit['@y'] + '}')
    $(id_sel + ' .unit-ap-info').html(unit['@ap'] + '/' + unit['@max_ap'])
    $(id_sel + ' .unit-dmg-info').html(unit['@dmg'])
    $(id_sel + ' .unit-def-info').html(unit['@def'])

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
      # building container with link, time to build, cost and build button
      b = $(document.createElement('div'))
        .attr('id', id)
        .addClass('open-building-screen')
        .appendTo('.modal.town .buildings')

      # open building link
      $open_building = $(document.createElement('a'))
        .html(building['@name'] + ' (' + building['@status'] + ')')
        .attr('id', open_building_sel)
        .attr('href', '#')
        .data('id', id)

      switch building['@status']
        when App.building_states['BUILDING_STATE_CAN_BE_BUILT']
          $open_building
            .addClass('builging_not_built')
            .click((e) ->
              e.preventDefault()
            )
          # building time
          $(document.createElement('div'))
            .addClass('builging_not_built')
            .html(building['@ttb_string'])
            .appendTo(b)

          $cost_res =
            $(document.createElement('div'))
              .addClass('building-cost')

          for res, count of building['@cost_res']
            if count
              $(document.createElement('div'))
                .addClass('cost-res')
                .addClass('cost-res-' + res)
                .html(count)
                .appendTo($cost_res)

          $cost_res.appendTo(b)
        when App.building_states['BUILDING_STATE_IN_PROGRESS']
          # if built then 'yellow' color
          $open_building
            .addClass('building_in_progress')
            .click((e) ->
              e.preventDefault()
            )
          # building time
          $(document.createElement('div'))
            .html(building['@ttb_string'])
            .appendTo(b)
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

      b.prepend($open_building)

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
      $a = $(".town .modal-town-actions-inner ##{action}")
      if $a.length == 0
        b = $(document.createElement('button'))
          .html(action_val.name)
          .attr('id', action)
          .data('id', action)
          .appendTo('.town .modal-town-actions-inner')
          .click(() ->
            action_val.callback this
          )
    # delete old actions

  init_town_workers: (workers, town_id, town_x, town_y) ->
    workers_on_work_hash = {}
    for worker in workers
      if worker['@x']? && worker['@y']?
        workers_on_work_hash[worker['@x'] + '_' + worker['@y']] = worker

    $('.workers-inner *').remove()
    range = [(-1 * App.TOWN_RADIUS)..App.TOWN_RADIUS]
    for dy in range
      row = $(document.createElement('div'))
        .addClass('worker-row')
        .appendTo('.modal.town .workers-inner')
      for dx in range
        adj_x = town_x + dx
        adj_y = town_y + dy
        worker_cell = $(document.createElement('div'))
              .addClass('worker-cell')
              .data('x', adj_x)
              .data('y', adj_y)
              .data('town_id', town_id)
        if adj_x >= 0 && adj_y >= 0 && adj_x <= App.MAX_COORD && adj_y <= App.MAX_COORD
          html = ''
          title = ''
          if dx == 0 && dy == 0
            html = 'Town'
            title = 'Town'
          else
            type = App.cells["#{adj_x}_#{adj_y}"]['@type']
            worker_cell
              .addClass('worker-cell-' + type)
            title = type

            html += adj_x + ',' + adj_y
            if workers_on_work_hash[adj_x + '_' + adj_y]
              title += ' Worker'
              worker_cell
                .addClass('worker-cell-has-worker')
                .click(() ->
                  App.free_worker($(this).data('town_id'), $(this).data('x'), $(this).data('y'))
                )
            else
              worker_cell
                .click(() ->
                  App.set_free_worker_to_xy($(this).data('town_id'), $(this).data('x'), $(this).data('y'))
                )
          worker_cell
            .attr('title', title)
            .html(html)
        else
          worker_cell
            .attr('title', 'Terra incognita')
            .html('TI')
        worker_cell
          .appendTo(row)  

  init_town_inventory: (inventory) ->
    $('.inventory-res').remove()
    for type, count of inventory
      if count
        $(document.createElement('div'))
          .addClass('inventory-res')
          .addClass('inventory-res-' + type)
          .attr('title', type + ' ' + count)
          .html(count)
          .appendTo('.town-inventory-inner')

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
