##
# Modal callbacks and stuff
class TownModalControls
  constructor: () ->
    _town_controls = this
    _this = this

    @open_building_id = null
    @last_town = null
    # fill in building modal
    @buildings =
      'barracs': {
        callback: () ->
          # $(document.createElement('div'))
          #   .addClass('modal-building-fill')
          #   .appendTo('.modal.town .modal-building-inner')

          # last_town = App.units[_this.last_town]
          # if last_town
          #   for company_id in last_town.adj_companies
          #     create_company_card(App.my_units[company_id])
      }
    $('.close-modal').click(() ->
      @open_building_id = null
      $('.modal').hide()
    )

  # create_company_card: (company) ->
  #   $(document.createElement('div'))
  #     .addClass('company-card')
  #     .addClass('pointer')
  #     .data('id', company.id)
  #     .attr('title', 'Add squad')
  #     .html("\
  #     Company ##{company.id} <br> \
  #     x,y: #{company.x},#{company.y}<br> \
  #     damage: #{company.damage} <br>\
  #     defence: #{company.defence} <br>\
  #     hp: #{company.hp} <br>\
  #     ap: #{company.ap} <br>\
  #     squads: #{company.squads}\
  #     ")
  #     .appendTo('.modal.building .modal-building-fill')
  #     .click(() ->
  #       App.add_squad_to_company($(this).data('id'))
  #     )

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

  open_town: (id) ->
    @last_town = id

  ##
  # @param {jQuery} button - card.open_building
  open_building: (button, title, actions) ->
    id = $(button).data('id')
    @buildings[id].callback()
    @open_building_id = id

window.TownModalControls = TownModalControls
