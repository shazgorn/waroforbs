class Map
  constructor: (@cell_dim_in_px, @block_dim_in_px, @block_dim_in_cells,
  @map_dim_in_blocks, cells) ->
    this_obj = this

    @set_size(App.options.map_height, App.options.map_width)

    #this.initTooltip()
    this.initDragHandler()
    this.addBlocks()
    if App.options.all_cells
      @addAllCells(cells)

  set_size: (height, width) ->
    $('#map').height(height * @cell_dim_in_px).width(width * @cell_dim_in_px)

  initTooltip: () ->
    $('#blocks').mousemove((e) ->

    )

  initDragHandler: () ->
    moving = false
    sx = 0
    sy = 0
    top = 0
    left = 0
    ee = 0
    setInterval(() ->
      if moving && ee
        dx = ee.pageX - sx
        dy = ee.pageY - sy
        unless dx in [-2..2] || dy in [-2..2]
          $('#blocks').css('top', top + dy + 'px').css('left', left + dx + 'px')
        false
    , 123)
    $('#map')
      .mousemove((e) ->
        ee = e
      )
      .mousedown((e) ->
        moving = true
        sx = e.pageX
        sy = e.pageY
        pos = $('#blocks').position()
        top = pos.top
        left = pos.left
      )
      .mouseup(() ->
        moving = false
      )

  addBlocks: () ->
    for block_x in [0..@map_dim_in_blocks-1]
      for block_y in [0..@map_dim_in_blocks-1]
        $(document.createElement('div'))
          .attr('id', "block_#{block_x}_#{block_y}")
          .addClass('block')
          # see Map::create_canvas_blocks
          .css('background-image', "url(img/bg/bg_#{block_x}_#{block_y}.png)")
          .css('left', "#{block_x * @block_dim_in_px}px")
          .css('top', "#{block_y * @block_dim_in_px}px")
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
      cell.attr('title', mapCell['@x'] + ',' + mapCell['@y'] + ' ' + mapCell['@type'])
    cell

  addAllCells: (cells) ->
    for id, cell of cells
      @addCell(cell['@x'], cell['@y'])

  applyDmgTo: (cell, dmg, type, timeout) ->
    d = $(document.createElement('span'))
    d.html(dmg)
    d.addClass('dmg').addClass('dmg_start').addClass("#{type}_dmg_start")
    $(cell).append(d)
    ###
    If you apply it instantly it will fuck you up. I do love timeouts anyway...
    ###
    setTimeout(() ->
        d.addClass('dmg_end').addClass("#{type}_dmg_end")
        setTimeout((() -> d.remove()), 1234)
    , timeout)

  dmg: (dmg, ca_dmg, a_id, d_id, a_delay, d_delay) ->
    @applyDmgTo($("#unit-#{d_id}").parent(), dmg,    'def', a_delay)
    @applyDmgTo($("#unit-#{a_id}").parent(), ca_dmg, 'att', d_delay)

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
    unit_jq = $("##{unit_id}")
    block_pos = unit_jq.parent().parent().position()
    if block_pos
      cell_pos = unit_jq.parent().position()
      map = $("#map")
      bias_top = (map.height() - @cell_dim_in_px) / 2
      bias_left = (map.width() - @cell_dim_in_px) / 2
      top = block_pos.top + cell_pos.top - bias_top
      left = block_pos.left + cell_pos.left - bias_left
      $('#blocks')
        .css('top', -1 * top + 'px')
        .css('left', -1 * left + 'px')
    else
      App.log('No position or no unit')

  # update unit div on map or append a new one
  append: (unit) ->
    $unit = $("#unit-#{unit.id}")
    # append to selector not jquery object!
    cell_sel = "#cell_#{unit.x}_#{unit.y}"
    $cell = $(cell_sel)
    if $cell.length == 0
      @addCell(unit.x, unit.y)
    if $unit.length == 0
      $unit = $(document.createElement('div'))
        .addClass('unit')
        .addClass(unit.css_class)
        .data('id', unit.id)
        .appendTo(cell_sel)
      if unit.attr_id
        $unit.attr('id', unit.attr_id)
      if unit.squads
        $(document.createElement('span'))
          .html(unit.squads)
          .addClass('player-unit-squad-info')
          .appendTo($unit)
    else if $unit.length == 1
      # unit already on map, update it
      if $unit.hasClass('green-orb')
        $unit.addClass(unit.css_class)
      if $unit.parent().data('x') != unit.x || $unit.parent().data('y') != unit.y
        $unit.appendTo(cell_sel)
      if unit.squads
        $unit.children('.player-unit-squad-info').html(unit.squads)
    if unit.title then $unit.attr('title', unit.title)
    $unit

this.Map = Map
