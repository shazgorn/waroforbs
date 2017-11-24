##
# Town province
class Province
  constructor: () ->
    console.log('new town province')

  ##
  # cell in town radius
  # displayed in the town modal window
  init_workers: (unit) ->
    # id => cell
    @cells = {}
    range = [(-1 * App.TOWN_RADIUS)..App.TOWN_RADIUS]
    for dy in range
      for dx in range
        x = @x + dx
        y = @y + dy
        id = "#{x}_#{y}"
        cell = new TownCell(id, x, y, @id)
        if App.cells[id]
          if @x == x && @y == y
            cell.html = cell.title = cell.type = 'town'
          else
            cell.set_type(App.cells[id]['@type'])
        else
          cell.html = '&nbsp;'
          cell.title = 'Hic sunt dracones'
        @cells[id] = cell
    for id, w of @workers
      if w['@x'] && w['@y']
        @cells[w['@x'] + '_' + w['@y']].has_worker = true

window.Province = Province
