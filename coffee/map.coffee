class Map
  constructor: (@cell_dim_in_px, @block_dim_in_px, @block_dim_in_cells,
  @map_dim_in_blocks) ->
    mhc = parseInt(localStorage.getItem('map_height_cells'))
    mwc = parseInt(localStorage.getItem('map_width_cells'))
    console.log(mhc)
    if !mhc || isNaN(mhc)
      mhc = 13
      localStorage.setItem('map_height_cells', mhc)
    $('#map_height').val(mhc)
    cell_px = @cell_dim_in_px
    this_obj = this
    $('#map_height').change((e) ->
      cells = parseInt($(this).val())
      $('#map').height(cell_px * cells)
      localStorage.setItem('map_height_cells', cells)
      # this_obj.center_on_hero('unit-' + @active_unit_id)
    )
    $('#map_width').change((e) ->
      cells = parseInt($(this).val())
      $('#map').width(cell_px * cells)
      localStorage.setItem('map_width_cells', cells)
      # this_obj.center_on_hero('unit-' + @active_unit_id)
    )
    if !mwc || isNaN(mwc)
      mwc = 13
      localStorage.setItem('map_width_cells', mwc)
    $('#map_width').val(mwc)
    $('#map').height(mhc * @cell_dim_in_px).width(mwc * @cell_dim_in_px)
    this.initTooltip()
    this.initDragHandler()
    this.addBlocks()

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
    $(document.createElement('div'))
      .attr('id', "cell_#{x}_#{y}")
      .data('x', x)
      .data('y', y)
      .addClass('cell')
      .css('left', left)
      .css('top', top)
      .appendTo("#block_#{block_x}_#{block_y}")

  applyDmgTo: (cell, dmg, type) ->
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
    , 123)

  dmg: (dmg, ca_dmg, a_id, d_id) ->
    @applyDmgTo($("#unit-#{d_id}").parent(), dmg,    'def')
    @applyDmgTo($("#unit-#{a_id}").parent(), ca_dmg, 'att')

  remove_units: () ->
    $('.unit').remove()

  remove_stale_units: (units) ->
    all_units_ids =
    for id, unit of units
      # keys are strings
      parseInt(id)
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
      console.log('No position or no unit')

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
    else if $unit.length == 1
      if $unit.parent().data('x') != unit.x || $unit.parent().data('y') != unit.y
        $unit.appendTo(cell_sel)
    if unit.title then $unit.attr('title', unit.title)
    $unit

this.Map = Map
