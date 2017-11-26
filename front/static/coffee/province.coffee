##
# Town province
class Province
  constructor: (@workers, @town_title, @town_x, @town_y, @town_id) ->
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
        @cells[w.x + '_' + w.y].worker = w

  make_cell_id: (x, y) ->
    "town_cell_#{x}_#{y}"

  create_cell: (cell) ->
    $(document.createElement('div'))
      .attr('id', @make_cell_id(cell.x, cell.y))
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
      cell.el = @create_cell(cell)
      $row.append(cell.el)
      if cell.worker
        cell.el.addClass('has-worker')
      else if !cell.worker
        cell.el.removeClass('has-worker')

  bind_actions_cells: () ->
    for id, cell of @cells
      cell.el.off('click')
      do (cell) =>
        cell.el.click(() =>
          if cell.worker
            @select_worker(cell.worker.pos, null)
          else if @selected_worker
            App.set_worker_to_xy(@town_id, @selected_worker, cell.x, cell.y)
        )

  select_worker: (pos, $w) ->
    unless $w
      $w = $("#worker-#{w.pos}")
    $('.worker-cell-selected').removeClass('worker-cell-selected')
    if $w.hasClass('worker-selected')
      # deselect worker
      $w.removeClass('worker-selected')
      @selected_worker = null
    else
      # select worker
      @selected_worker = pos
      $('.worker-selected').removeClass('worker-selected')
      $w.addClass('worker-selected')
      $('#' + @make_cell_id(@workers[pos].x, @workers[pos].y)).addClass('worker-cell-selected')

  select_worker_handler: (pos, $w) ->
    () =>
      @select_worker(pos, $w)

  draw_workers: () ->
    for pos, w of @workers
      $w = $(document.createElement('span'))
        .attr('id', "worker-#{w.pos}")
        .addClass('worker')
        .addClass('worker-' + w.type)
        .attr('title', w.pos + ' ' + w.res_title)
        .appendTo('.workers-list')
        do (w, $w) =>
          $w.click(@select_worker_handler(w.pos, $w))

  update: (workers, town_title) ->
    if @town_title != town_title
      @town_title = town_title
      $('#' + @make_cell_id(@town_x, @town_y))
        .attr('title', @town_title)
    for pos, w of workers
      if w.x != @workers[w.pos].x || w.y != @workers[w.pos].y
        if @cells[@workers[w.pos].x + '_' + @workers[w.pos].y]
          @cells[@workers[w.pos].x + '_' + @workers[w.pos].y].worker = null
          @cells[@workers[w.pos].x + '_' + @workers[w.pos].y].el
            .removeClass('has-worker')
            .removeClass('worker-cell-selected')
        @workers[w.pos] = w
        @cells[@workers[w.pos].x + '_' + @workers[w.pos].y].el.addClass('has-worker')
        if w.pos == @selected_worker
          @cells[@workers[w.pos].x + '_' + @workers[w.pos].y].el.addClass('worker-cell-selected')

window.Province = Province
