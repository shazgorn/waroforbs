class Map
  constructor: (@cell_dim_in_px, @block_dim_in_px, @block_dim_in_cells,
  @map_dim_in_blocks, cells) ->
    this_obj = this
    #this.initTooltip()
    this.addBlocks()
    if App.options.all_cells
      @addAllCells(cells)
    this.initDragHandler()
    $('#blocks')
      .width(@block_dim_in_ip * @map_dim_in_blocks)
      .height(@block_dim_in_ip * @map_dim_in_blocks)

  # initTooltip: () ->
  #   $('#blocks').mousemove((e) ->
  #   )

  initDragHandler: () ->
    moving = false
    sx = 0
    sy = 0
    top = 0
    left = 0
    ee = 0
    $last_block = $('.block:last-of-type')
    pos = $last_block.position()
    h = pos.top + $last_block.height()
    w = pos.left + $last_block.width()
    ww = $(window).width() / 2
    wh = $(window).height() / 2
    min_x = ww - w - $('#right-col').width() / 2
    min_y = wh - h - $('#log').height() / 2
    max_x = ww
    max_y = wh
    setInterval(() ->
      if moving && ee
        dx = ee.pageX - sx
        dy = ee.pageY - sy
        unless dx in [-2..2] || dy in [-2..2]
          new_x = left + dx
          new_y = top + dy
          if new_x > max_x
            new_x = max_x
          if new_y > max_y
            new_y = max_y
          if new_x < min_x
            new_x = min_x
          if new_y < min_y
            new_y = min_y
          $('#blocks')
            .width(@block_dim_in_ip * @map_dim_in_blocks)
            .height(@block_dim_in_ip * @map_dim_in_blocks)
            .css('top', new_y + 'px')
            .css('left', new_x + 'px')
        false
    , 10)
    $('#blocks')
      .mousemove((e) ->
        ee = e
      )
      .mousedown((e) ->
        if e.button == 0
          moving = true
          sx = e.pageX
          sy = e.pageY
          pos = $('#blocks').position()
          top = pos.top
          left = pos.left
      )
    $(document).mouseup(() ->
      moving = false
    )

  addBlocks: () ->
    for block_x in [1..@map_dim_in_blocks]
      for block_y in [1..@map_dim_in_blocks]
        blockClass = 'block'
        top_pos = block_y * @block_dim_in_px
        left_pos = block_x * @block_dim_in_px
        if block_y == 1
          blockClass += ' block-top'
          top_pos -= 5
        if block_y == @map_dim_in_blocks
          blockClass += ' block-bottom'
        if block_x == 1
          blockClass += ' block-left'
          left_pos -= 5
        if block_x == @map_dim_in_blocks
          blockClass += ' block-right'
        b = $(document.createElement('div'))
          .attr('id', "block_#{block_x}_#{block_y}")
          .addClass(blockClass)
          .css('background-image', "url(/img/#{App.blocks[block_x][block_y].path})")
          .css('left', "#{left_pos}px")
          .css('top', "#{top_pos}px")
          .appendTo('#blocks')

  addCell: (x, y) ->
    block_x = (x - 1) // @block_dim_in_cells + 1
    block_y = (y - 1) // @block_dim_in_cells + 1
    left = (x - 1) % 10 * @cell_dim_in_px
    top = (y - 1) % 10 * @cell_dim_in_px
    tile = App.cells[x][y]
    cell = $(document.createElement('div'))
      .attr('id', "cell_#{x}_#{y}")
      .data('x', x)
      .data('y', y)
      .addClass('cell')
      .css('left', left)
      .css('top', top)
      .appendTo("#block_#{block_x}_#{block_y}")
    if tile
      cell.attr(
        'title',
        tile.x + ',' + tile.y + ' ' + tile.type_title
      )
    cell

  addAllCells: (cells) ->
    for id, cell of cells
      @addCell(cell.x, cell.y)

  applyCasualtiesTo: (cell, wounds, kills, type, timeout) ->
    d = $(document.createElement('span'))
      .addClass('casualties')
      .addClass('casualties-start')
      .addClass("#{type}-casualties")
      .addClass("#{type}-casualties-start")
      .append(
        $(document.createElement('span'))
        .addClass('wounds')
        .html(wounds)
      )
      .append(
        $(document.createElement('span'))
        .addClass('kills')
        .html(kills)
      )
      .appendTo(cell)

    ###
    If you apply it instantly it will fuck you up. I do love timeouts anyway...
    ###
    setTimeout(() ->
      d
        .removeClass('casualties-start')
        .addClass('casualties-end')
        .removeClass("#{type}-casualties-start")
        .addClass("#{type}-casualties-end")
      setTimeout((() -> d.remove()), 1234)
    , timeout)

  casualties: (a_wounds, a_kills, d_wounds, d_kills, a_id, d_id, a_delay, d_delay) ->
    @applyCasualtiesTo($("#unit-#{d_id}").parent(), d_wounds, d_kills, 'defender', a_delay)
    @applyCasualtiesTo($("#unit-#{a_id}").parent(), a_wounds, a_kills, 'attacker', d_delay)

  center_on_hero: (unit_id) ->
    $unit = $("##{unit_id}")
    block_pos = $unit.parent().parent().position()
    if block_pos
      cell_pos = $unit.parent().position()
      map = $("#map")
      bias_top = (map.height() - @cell_dim_in_px) / 2
      bias_left = (map.width() - @cell_dim_in_px) / 2
      bias_top -= $('#log').height() / 2
      bias_left -= $('#right-col').width() / 2
      top = block_pos.top + cell_pos.top - bias_top
      left = block_pos.left + cell_pos.left - bias_left
      $('#blocks')
        .css('top', -1 * top + 'px')
        .css('left', -1 * left + 'px')
    else
      # TODO: translate me
      App.log({message: 'No position or no unit', type: 'error', time: 'Interface error'})

  appendElementToCell: (element, x, y) ->
    # append to selector not jQuery object!
    cell_sel = "#cell_#{x}_#{y}"
    $cell = $(cell_sel)
    if $cell.length == 0
      @addCell(x, y)
    $(element).appendTo(cell_sel)

  # update unit div on map or append a new one
  append: (unit) ->
    $unit = $("#unit-#{unit.id}")
    if $unit.length == 0

    else if $unit.length == 1
      # unit already on map, update it
      # add size class for orb (normal, medium, small)
      if $unit.hasClass('green-orb')
        $unit.addClass(unit.css_class)
      # move unit
      if $unit.parent().data('x') != unit.x ||
          $unit.parent().data('y') != unit.y
        $unit.appendTo(cell_sel)
    $unit

this.Map = Map
