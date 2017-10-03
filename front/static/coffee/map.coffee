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
    for block_x in [0..@map_dim_in_blocks-1]
      for block_y in [0..@map_dim_in_blocks-1]
        blockClass = 'block'
        top_pos = block_y * @block_dim_in_px
        left_pos = block_x * @block_dim_in_px
        if block_y == 0
          blockClass += ' block-top'
          top_pos -= 5
        if block_y == @map_dim_in_blocks-1
          blockClass += ' block-bottom'
        if block_x == 0
          blockClass += ' block-left'
          left_pos -= 5
        if block_x == @map_dim_in_blocks-1
          blockClass += ' block-right'
        b = $(document.createElement('div'))
          .attr('id', "block_#{block_x}_#{block_y}")
          .addClass(blockClass)
          # see Map::create_canvas_blocks
          .css('background-image', "url(img/bg/bg_#{block_x}_#{block_y}.png)")
          .css('left', "#{left_pos}px")
          .css('top', "#{top_pos}px")
          .appendTo('#blocks')

  addCell: (x, y) ->
    block_x = x // @block_dim_in_cells
    block_y = y // @block_dim_in_cells
    left = x % 10 * @cell_dim_in_px
    top = y % 10 * @cell_dim_in_px
    mapCell = App.cells[x + '_' + y]
    cell = $(document.createElement('div'))
      .attr('id', "cell_#{x}_#{y}")
      .data('x', x)
      .data('y', y)
      .addClass('cell')
      .css('left', left)
      .css('top', top)
      .appendTo("#block_#{block_x}_#{block_y}")
    if mapCell
      cell.attr(
        'title',
        mapCell['@x'] + ',' + mapCell['@y'] + ' ' + mapCell['@type']
      )
    cell

  addAllCells: (cells) ->
    for id, cell of cells
      @addCell(cell['@x'], cell['@y'])

  applyDmgTo: (cell, wounds, kills, type, timeout) ->
    d = $(document.createElement('span'))
      .addClass('dmg')
      .addClass('dmg-start')
      .addClass("#{type}-dmg-start")
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
        .removeClass('dmg-start')
        .addClass('dmg-end')
        .removeClass("#{type}-dmg-start")
        .addClass("#{type}-dmg-end")
      setTimeout((() -> d.remove()), 1234)
    , timeout)

  dmg: (a_wounds, a_kills, d_wounds, d_kills, a_id, d_id, a_delay, d_delay) ->
    @applyDmgTo($("#unit-#{d_id}").parent(), d_wounds, d_kills,    'def', a_delay)
    @applyDmgTo($("#unit-#{a_id}").parent(), a_wounds, a_kills, 'att', d_delay)

  remove_units: () ->
    $('.unit').remove()

  remove_stale_units: (units) ->
    # keys are strings
    all_units_ids = (parseInt(id) for id, unit of units)
    $('.unit').each((i, unit) ->
      id = $(unit).data('id')
      if $.inArray(id, all_units_ids) == -1
        $("#unit-#{id}").remove()
    )

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
