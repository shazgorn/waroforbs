##
# Modal callbacks and stuff
class TownModalControls
  constructor: () ->
    _town_controls = this
    _this = this

    @last_town = null
    $('.close-modal').click(() ->
      $('.modal').hide()
    )

  update: () ->
    console.log('update town modal controls')

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
