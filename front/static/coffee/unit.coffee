# - rename 'css_' to 'attr_'
# - really?
# unit title - title attribute for unit's element on the map, building title is another thing

class Model
  constructor: (hash) ->
    # view property is a link to view
    @view = null
    @controls = null # only player's models has it

  update: (hash) ->
    return

##
# Every unit should have every property no matter player's or not
# till visibility options arrive
class Unit extends Model
  constructor: (unit, @own) ->
    super unit
    @_unit = unit
    @id = unit.id
    @attr_id = "unit-#{@id}"
    @type = unit.type
    @damage = unit.damage
    @defence = unit.defence
    @dead = unit.dead
    @inventory =  unit.inventory
    @user_id = unit.user_idnull
    @user_name = unit.user_name
    if !@dead
      @need_to_move = true
    @title = unit.name
    unless @own
      @title += ' [' + unit.user_name + ']'

  update: (unit) ->
    return if @dead
    if unit.dead
      @dead = unit.dead
      @need_to_move = false
      @view.remove_element()
      if @controls
        @controls.remove_element()
      return
    @need_to_move = (@x != unit.x || @y != unit.y)
    @x = unit.x
    @y = unit.y
    @ap = unit.ap
    @life = unit.life
    @wounds = unit.wounds
    @name = unit.name
    @adj_companies = unit.adj_companies
    if @controls
      @controls.inventory_view.sync_resources(@inventory, unit.inventory)
    if @modal
      @modal.inventory_view.sync_resources(@inventory, unit.inventory)
    for res, q of unit.inventory
      @inventory[res] = q
    if @own
      @title = unit.name
    else
      @title = unit.name + ' [' + unit.user_name + ']'

  create_view: () ->
    @view = new UnitView(this, @own)

  update_view: () ->
    if @view
      @view.update(this)

  create_controls: () ->
    if @own
      @controls = new UnitControls(this)

  update_controls: () ->
    if @controls
      @controls.update(this)

  create_modal: () ->
    if @own && @type == 'town'
      @modal = new TownModal(this)
      @modal.bind_open_handler([@view.element])
      for key, building_card of @buildings_cards
        building_card.set_town_modal(@modal, @buildings[key])

  remove: () ->
    console.log('remove ' + @id)
    if @view
      @view.remove_element()
    if @controls
      @controls.remove_element()
    if @modal
      @modal.clean_up()

  init_buildings: (unit) ->
    @buildings = {}
    @buildings_cards = {}
    for key, building of unit.buildings
      @buildings[key] = new Building(key, building)
      @buildings_cards[key] = BuildingCard.create(building)
    console.log(@buildings_cards)

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
    @workers = unit['workers']
    for id, w of @workers
      if w['@x'] && w['@y']
        @cells[w['@x'] + '_' + w['@y']].has_worker = true

  update_buildings: (unit) ->
    for key, building of @buildings
      building.update(unit['buildings'][key])
    for key, building_card of @buildings_cards
      building_card.update(unit['buildings'][key])

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

class Building
  constructor: (key, building) ->
    @id = key
    @name = building['name']
    @title = building['title']
    @status = building['status']
    @ttb_string = building['ttb_string']
    @cost_res = building['cost_res']
    @actions = building['actions']

  update: (building) ->
    @status = building['status']
    @ttb_string = building['ttb_string']

window.Unit = Unit
