class Map
  constructor: (@cell_dim_in_px, @block_dim_in_px, @block_dim_in_cells,
  @map_dim_in_blocks) ->
    mhc = parseInt(localStorage.getItem('map_height_cells'))
    mwc = parseInt(localStorage.getItem('map_width_cells'))
    unless mhc?
      mhc = 13
      localStorage.setItem('map_height_cells', mhc)
    $('#map_height').val(mhc)
    cell_px = @cell_dim_in_px
    this_obj = this
    $('#map_height').change((e) ->
      cells = parseInt($(this).val())
      $('#map').height(cell_px * cells)
      localStorage.setItem('map_height_cells', cells)
      # this_obj.center_on_hero('hero_' + @active_unit_id)
    )
    $('#map_width').change((e) ->
      cells = parseInt($(this).val())
      $('#map').width(cell_px * cells)
      localStorage.setItem('map_width_cells', cells)
      # this_obj.center_on_hero('hero_' + @active_unit_id)
    )
    unless mwc?
      mwc = 13
      localStorage.setItem('map_height_cells', mwc)
    $('#map_width').val(mwc)
    $('#map').height(mhc * @cell_dim_in_px).width(mwc * @cell_dim_in_px)
    this.initTooltip()
    this.initDragHandler()
    this.addBlocks()

  initTooltip: () ->
    $('#blocks').mousemove((e) ->
      #console.log(e)
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

  dmg: (x, y, dmg, ca_dmg) ->
    this.applyDmgTo($("#cell_#{x}_#{y}"), dmg, 'def')
    this.applyDmgTo($('#the_hero').parent(), ca_dmg, 'att')

  remove_units: () ->
    $('.unit').remove()

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

  append: (unit) ->
    cell_sel = "#cell_#{unit.x}_#{unit.y}"
    cell = $(cell_sel)
    if cell.length == 0
      this.addCell(unit.x, unit.y)
    o = $(document.createElement('div'))
      .addClass('unit')
      .addClass(unit.css_class)
      .appendTo(cell_sel);
    if unit.id
      o.attr('id', unit.id)
    if unit.title then o.attr('title', unit.title)
    o

this.Map = Map
