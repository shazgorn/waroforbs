class TownCell
  constructor: (id, x, y, town_id) ->
    @id = id
    @x = x
    @y = y
    @type = ''
    @title = ''
    @html = ''
    @town_id = town_id
    @set_type(@type)
    @has_worker = false
    @is_town = false
    # $DOMElement
    @el = null

  set_type: (type) ->
    @type = type
    @title = "#{@x},#{@y} #{@type}"
    @html = "#{@x},#{@y}"

  trigger_worker: () ->
    if @has_worker
      App.free_worker(@town_id, @x, @y)
    else
      App.set_free_worker_to_xy(@town_id, @x, @y)

window.TownCell = TownCell
