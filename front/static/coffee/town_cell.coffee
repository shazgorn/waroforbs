class TownCell
  constructor: (x, y, town_id) ->
    @x = x
    @y = y
    @type = ''
    @type_title = ''
    @html = ''
    @town_id = town_id
    @worker = null
    @is_town = false
    @in_map = false
    # $DOMElement
    @el = null

window.TownCell = TownCell
