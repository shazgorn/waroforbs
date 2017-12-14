##
# Town province
class Province
  constructor: (@workers, @town_x, @town_y, @town_id, @town_title, @town_radius) ->
    # id => cell
    @selected_worker = null
    @cells = {}
    town_range = [(-1 * @town_radius)..@town_radius]
    @range_x = [(-1 * @town_radius + @town_x)..(@town_radius + @town_x)]
    @range_y = [(-1 * @town_radius + @town_y)..(@town_radius + @town_y)]
    cell_y = cell_x = 0
    for dy in town_range
      cell_x++
      for dx in town_range
        cell_y++
        x = @town_x + dx
        y = @town_y + dy
        cell = new TownCell(x, y, @town_id)
        if App.cells[x]? && App.cells[x][y]?
          cell.in_map = true
          if @town_x == x && @town_y == y
            # town cell
            cell.html = '&nbsp;'
            cell.title = @town_title
            cell.type = App.cells[x][y].type
            cell.is_town = true
          else
            # non town cell
            cell.type = App.cells[x][y].type
            cell.title = "#{x},#{y} #{App.cells[x][y].type_title}"
            cell.html = "#{x},#{y}"
        else
          # out of map
          cell.html = '&nbsp;'
          cell.title = 'Hic sunt dracones ' + x + ' ' + y
          cell.type = 'darkness'
        unless @cells[x]?
          @cells[x] = {}
        @cells[x][y] = cell
    for id, w of @workers
      if w.x && w.y
        @cells[w.x][w.y].worker = w

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
      .appendTo('.province-inner')

  draw_town_cells: () ->
    for x in @range_x
      for y in @range_y
        cell = @cells[x][y]
        $row = $("#worker-row-#{y}")
        if $row.length == 0
          $row = @create_row(y)
        cell.el = @create_cell(cell)
        $row.append(cell.el)
        if cell.worker
          cell.el.addClass('has-worker')
        else if !cell.worker
          cell.el.removeClass('has-worker')

  bind_actions_cells: () ->
    for x in @range_x
      for y in @range_y
        if @cells[x][y].in_map && !@cells[x][y].is_town
          do (x, y) =>
            @cells[x][y].el.click(() =>
              if @cells[x][y].worker
                @select_worker(@cells[x][y].worker.pos, null)
              else if @selected_worker
                App.set_worker_to_xy(@town_id, @selected_worker, x, y)
            )

  select_worker: (pos, $w) ->
    unless $w
      $w = $("#worker-#{pos}")
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
      $w = $(document.createElement('div'))
        .attr('id', "worker-#{w.pos}")
        .addClass('worker')
        .addClass('worker-' + w.type)
        .attr('title', w.profession)
      $winfo = $(document.createElement('div'))
        .addClass('worker-info')
      $winfo_time = $(document.createElement('div'))
        .addClass('worker-info-time')
        .append(
          $(document.createElement('span'))
            .attr('id', "worker-#{pos}-info-production-time")
            .html(w.production_time),
          $(document.createTextNode('/')),
          $(document.createElement('span'))
            .attr('id', "worker-#{pos}-info-delivery-time")
            .html(w.delivery_time)
          $(document.createTextNode('/')),
          $(document.createElement('span'))
            .attr('id', "worker-#{pos}-info-total-time")
            .html(w.total_time)
        )
        .appendTo($winfo)
      $winfo_timebar_container = $(document.createElement('div'))
        .addClass('worker-timebar-container')
        .appendTo($winfo)
      $winfo_timebar = $(document.createElement('div'))
        .addClass('worker-timebar')
        .attr('id', "worker-#{pos}-timebar")
        .appendTo($winfo_timebar_container)
      @update_timebar($winfo_timebar, w)
      $wr = $(document.createElement('div'))
        .addClass('worker-row')
        .appendTo('.workers-list')
        .append($w)
        .append($winfo)
      do (w, $w) =>
        $w.click(@select_worker_handler(w.pos, $w))

  update_timebar: ($timebar, w) ->
    $timebar.css('width', parseInt(w.remaining_time / w.total_time * 100) + 'px')

  update: (workers, town_title) ->
    if @town_title != town_title
      @town_title = town_title
      $('#' + @make_cell_id(@town_x, @town_y))
        .attr('title', @town_title)
    for pos, w of workers
      if w.type != @workers[w.pos].type
        $('#' + "worker-#{w.pos}")
          .removeClass("worker-#{@workers[w.pos].type}")
          .addClass("worker-#{w.type}")
      if w.x != @workers[w.pos].x || w.y != @workers[w.pos].y
        if @workers[w.pos].x && @workers[w.pos].y && @cells[@workers[w.pos].x][@workers[w.pos].y]
          old_cell = @cells[@workers[w.pos].x][@workers[w.pos].y]
          old_cell.worker = null
          old_cell.el
            .removeClass('has-worker')
            .removeClass('worker-cell-selected')
        new_cell = @cells[w.x][w.y]
        new_cell.el.addClass('has-worker')
        new_cell.worker = w
        # moving selected worker, preserve selection
        if w.pos == @selected_worker
          new_cell.el.addClass('worker-cell-selected')
      for time in ['production', 'delivery', 'total']
        if w["#{time}_time"] != @workers[w.pos]["#{time}_time"]
          $("#worker-#{pos}-info-#{time}-time").html(w["#{time}_time"])
      if w.remaining_time != @workers[w.pos].remaining_time
        @update_timebar($("#worker-#{pos}-timebar"), w)
      @workers[w.pos] = w

window.Province = Province
