##
# Modal callbacks and stuff
class TownModalControls
  constructor: () ->
    _town_controls = this
    _this = this

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
          #   for squad_id in last_town.adj_companies
          #     create_squad_card(App.my_units[squad_id])
      }
    $('.close-modal').click(() ->
      $('.modal').hide()
    )

  # create_squad_card: (squad) ->
  #   $(document.createElement('div'))
  #     .addClass('squad-card')
  #     .addClass('pointer')
  #     .data('id', squad.id)
  #     .attr('title', 'Add squad')
  #     .html("\
  #     Squad ##{squad.id} <br> \
  #     x,y: #{squad.x},#{squad.y}<br> \
  #     damage: #{squad.damage} <br>\
  #     defence: #{squad.defence} <br>\
  #     hp: #{squad.hp} <br>\
  #     ap: #{squad.ap} <br>\
  #     squads: #{squad.squads}\
  #     ")
  #     .appendTo('.modal.building .modal-building-fill')
  #     .click(() ->
  #       App.add_squad_to_squad($(this).data('id'))
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

window.TownModalControls = TownModalControls
