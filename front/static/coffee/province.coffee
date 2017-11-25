##
# Town province
class Province
  constructor: (@workers, @town_x, @town_y, @town_id, @town_title) ->
    # id => cell
    @selected_worker = null
    @cells = {}
    range = [(-1 * App.TOWN_RADIUS)..App.TOWN_RADIUS]
    for dy in range
      for dx in range
        x = @town_x + dx
        y = @town_y + dy
        id = "#{x}_#{y}"
        cell = new TownCell(id, x, y, @town_id)
        if App.cells[id]
          if @town_x == x && @town_y == y
            # town cell
            cell.html = '&nbsp;'
            cell.title = @town_title
            cell.type = App.cells[id].type
            cell.is_town = true
          else
            # non town cell
            cell.type = App.cells[id].type
            cell.title = "#{x},#{y} #{App.cells[id].type_title}"
            cell.html = "#{x},#{y}"
        else
          # out of map
          cell.html = '&nbsp;'
          cell.title = 'Hic sunt dracones'
          cell.type = 'darkness'
        @cells[id] = cell
    for id, w of @workers
      if w.x && w.y
        @cells[w.x + '_' + w.y].has_worker = true

  create_cell: (cell) ->
    $(document.createElement('div'))
      .attr('id', "town_cell_#{cell.x}_#{cell.y}")
      .addClass('worker-cell')
      .addClass("worker-cell-#{cell.type}")
      .addClass(if cell.is_town then 'worker-cell-town' else '')
      .attr('title', cell.title)
      .html(cell.html)

  create_row: (id) ->
    $(document.createElement('div'))
      .attr('id', "worker-row-#{id}")
      .addClass('worker-row')
      .appendTo('.modal.town .workers-inner')

  draw_town_cells: () ->
    for id, cell of @cells
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

  bind_actions_cells: () ->
    for id, cell of @cells
      cell.el.off('click')
      do (cell) ->
        cell.el.click(() ->
          cell.trigger_worker()
        )

  select_worker: (n, $w) ->
    () =>
      @selected_worker = n
      $('.worker-selected').removeClass('worker-selected')
      $w.addClass('worker-selected')

  draw_workers: () ->
    for w in @workers
      $w = $(document.createElement('span'))
        .attr('id', "worker-#{w.name}")
        .addClass('worker')
        .addClass('worker-' + w.type)
        .attr('title', w.name + ' ' + w.res_title)
        .appendTo('.workers-list')
      $w.click(@select_worker(w.name, $w))


window.Province = Province
