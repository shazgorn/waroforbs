class TownControls
  constructor: () ->
    _town_controls = this
    @open_building_id = null
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
            b = _town_controls.banner_card(banner, 'Banner')
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
              b = _town_controls.banner_card(banner, 'Create company')
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
    $('.close-modal').click(() ->
      @open_building_id = null
      $('.modal').hide()
    )


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
                .attr('title', "#{res} #{count}")
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
        if adj_x >= 0 && adj_y >= 0 && adj_x <= App.MAX_CELL_IDX && adj_y <= App.MAX_CELL_IDX
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

  open_building: (button) ->
    $('.modal').hide()
    id = $(button).data('id')
    $('.modal.building').show()
    $('.modal.building .modal-title').html(@buildings[id].name)
    @fill_building_modal(id)
    @open_building_id = id

  fill_building_modal: (id) ->
    @buildings[id].callback()

  banner_card: (banner, title) ->
    $(document.createElement('div'))
      .addClass('banner-card')
      .data('id', banner['@id'])
      .attr('title', title)
      .html("Banner ##{banner['@id']} <br> dmg: #{banner['@mod_dmg']} <br> def: #{banner['@mod_def']} <br> hp: #{banner['@mod_max_hp']} <br>ap: #{banner['@mod_max_ap']} <br>unit_id: #{banner['@unit_id']}")
      .appendTo('.modal.building .modal-building-inner')



window.TownControls = TownControls
