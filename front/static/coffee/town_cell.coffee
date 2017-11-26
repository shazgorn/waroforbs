class TownCell
  constructor: (id, x, y, town_id) ->
    @id = id
    @x = x
    @y = y
    @type = ''
    @type_title = ''
    @html = ''
    @town_id = town_id
    @worker = null
    @is_town = false
    # $DOMElement
    @el = null

window.TownCell = TownCell
