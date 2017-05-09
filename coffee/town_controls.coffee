class TownControls
  constructor: () ->
    _town_controls = this
    _this = this

    @open_building_id = null
    @last_town = null
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

          last_town = App.units[_this.last_town]
          if last_town
            for company_id in last_town.adj_companies
              create_company_card(App.my_units[company_id])
      }
    $('.close-modal').click(() ->
      @open_building_id = null
      $('.modal').hide()
    )

  create_company_card: (company) ->
    $(document.createElement('div'))
      .addClass('company-card')
      .addClass('pointer')
      .data('id', company.id)
      .attr('title', 'Add squad')
      .html("\
      Company ##{company.id} <br> \
      x,y: #{company.x},#{company.y}<br> \
      damage: #{company.damage} <br>\
      defence: #{company.defence} <br>\
      hp: #{company.hp} <br>\
      ap: #{company.ap} <br>\
      squads: #{company.squads}\
      ")
      .appendTo('.modal.building .modal-building-fill')
      .click(() ->
        App.add_squad_to_company($(this).data('id'))
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
        .appendTo('.modal.town .buildings-inner')

      # open building link
      $open_building = $(document.createElement('a'))
        .html(building['@name'])
        .attr('id', open_building_sel)
        .attr('href', '#')
        .data('id', id)

      switch building['@status']
        when App.building_states['BUILDING_STATE_CAN_BE_BUILT']
          b.addClass('building-not-built')
          $open_building
            .click((e) ->
              e.preventDefault()
            )
          # building time
          $(document.createElement('div'))
            .addClass('building-time')
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
          b.addClass('building-in-progress')
          $open_building
            .click((e) ->
              e.preventDefault()
            )
          # building time
          $(document.createElement('div'))
            .addClass('building-time')
            .html(building['@ttb_string'])
            .appendTo(b)
        when App.building_states['BUILDING_STATE_BUILT']
          b.addClass('building-built')
          $open_building
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
      else if building['@status'] == 0 && $("##{id}").length == 1 &&
          $("##{id} button").length == 0
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

  create_cell: (cell) ->
    $(document.createElement('div'))
      .attr('id', "town_cell_#{cell.x}_#{cell.y}")
      .addClass('worker-cell')
      .addClass("worker-cell-#{cell.type}")
      .attr('title', cell.title)
      .html(cell.html)

  create_row: (id) ->
    $(document.createElement('div'))
      .attr('id', "worker-row-#{id}")
      .addClass('worker-row')
      .appendTo('.modal.town .workers-inner')

  draw_town_cells_new: (town) ->
    for id, cell of town.cells
      $row = $("#worker-row-#{cell.y}")
      if $row.length == 0
        $row = @create_row(cell.y)
      $cell = $("#town_cell_#{cell.id}")
      if $cell.length == 0
        $cell = @create_cell(cell)
        $row.append($cell)
      cell.el = $cell
      if cell.has_worker && !$cell.hasClass('worker-cell-has-worker')
        $cell.addClass('worker-cell-has-worker')
      else if !cell.has_worker && $cell.hasClass('worker-cell-has-worker')
        $cell.removeClass('worker-cell-has-worker')

  bind_actions_cells: (town) ->
    for id, cell of town.cells
      cell.el.off('click')
      do (cell) ->
        cell.el.click(() ->
          cell.trigger_worker()
        )

  draw_workers: (workers) ->
    $('.worker').remove()
    for w in workers
      $w = $(document.createElement('span'))
        .addClass('worker')
        .addClass('worker-' + w['@type'])
        .attr('title', w['@type'])
        .appendTo('.workers-list')

  init_town_workers: (town) ->
    @draw_workers(town.workers)
    @draw_town_cells_new(town)
    @bind_actions_cells(town)

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

  open_town: (id) ->
    @last_town = id
    $('.modal.town').show()

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
      .html("Banner ##{banner['@id']} <br>\
      dmg: #{banner['@mod_dmg']} <br> \
      def: #{banner['@mod_def']} <br> \
      hp: #{banner['@mod_max_hp']} <br>\
      ap: #{banner['@mod_max_ap']} <br>\
      unit_id: #{banner['@unit_id']}")
      .appendTo('.modal.building .modal-building-inner')



window.TownControls = TownControls
