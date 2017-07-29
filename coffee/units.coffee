# - rename 'css_' to 'attr_'
# - really?

class Model
  constructor: (hash) ->
    # view property is a link to view
    @view = null
    @controls = null

  update: (hash) ->
    return

class Unit extends Model
  constructor: (unit) ->
    super unit
    @_unit = unit
    @id = unit.id
    @attr_id = "unit-#{@id}"
    @x = unit.x
    @y = unit.y
    @type = unit.type
    @damage = unit.damage
    @defence = unit.defence
    @dead = unit.dead
    @life = unit.life
    @ap = unit.ap
    @user_id = null
    @user_name = null
    if !@dead
      @need_to_move = true

  update: (unit) ->
    return if @dead
    if unit.dead
      @dead = unit.dead
      @need_to_move = false
      @view.remove_element()
      if @controls
        @controls.remove_element()
      return
    @need_to_move = !@dead && (@x != unit.x || @y != unit.y)
    if @x != unit.x
      @x = unit.x
      # view.set_x(@x)
    if @y != unit.y
      @y = unit.y
      # view.set_y(@x)
    if @ap != unit.ap
      @ap = unit.ap
      # view.set_ap(@ap)


class Company extends Unit
  constructor: (unit) ->
    super unit
    @user_id = unit.user_id
    @user_name = unit.user_name
    @update_title(unit)

  update_title: () ->
    @title = @user_name

  update: (unit) ->
    super unit
    @update_title()

class PlayerCompany extends Company
  constructor: (unit) ->
    super unit
    @css_class = 'player-unit player-hero'
    @life = unit.life

  create_view: () ->
    if !@dead
      @view = new PlayerCompanyView(this)
      @controls = new PlayerCompanyControlsView(this)

  update: (unit) ->
    super unit
    return if @dead
    if @life != unit.life
      @life = unit.life
      @view.set_life(@life)
    @controls.update(this)


class OtherPlayerCompany extends Company
  constructor: (unit) ->
    super unit
    @css_class = 'other-player-hero'

  create_view: () ->
    if !@dead
      @view = new OtherPlayerCompanyView(this)

  update: (unit) ->
    super unit
    return if @dead
    if @life != unit.life
      @life = unit.life
      @view.set_life(@life)

class GreenOrb extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'green-orb'
    @title = @life
    if @life < 50
      @css_class += ' orb-sm'
    else if @life < 100
      @css_class += ' orb-md'
    else
      @css_class += ' orb'

  create_view: () ->
    @view = new GreenOrbView(this)



class BlackOrb extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'black-orb'
    @title = @life
    if @life < 500
      @css_class += ' orb-sm'
    else if @life < 700
      @css_class += ' orb-md'
    else
      @css_class += ' orb'

  create_view: () ->
    if !@dead
      @view = new BlackOrbView(this)



class Town extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'town'
    @title = unit.user_name + ' Town'

##
# cell in town radius
# displayed in the town modal window
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


class PlayerTown extends Town
  constructor: (unit) ->
    super unit
    @css_class = 'player-unit player-town'
    @adj_companies = unit['@adj_companies']
    @buildings = {}
    for key, building of unit['@buildings']
      @buildings[key] = new Building(key, building)
    @inventory_items = {}
    for key, inventory_item of unit['@inventory']
      @inventory_items[key] = new TownInventoryItem(key, inventory_item)
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
    @workers = unit['@workers']
    for id, w of @workers
      if w['@x'] && w['@y']
        @cells[w['@x'] + '_' + w['@y']].has_worker = true

  update: (town) ->
    super town
    return if @dead
    for key, building of @buildings
      building.update town['@buildings'][key]
    for key, inventory_item of @inventory_items
      inventory_item.update town['@inventory'][key]

  create_view: () ->
    if !@dead
      @view = new PlayerTownView(this)
      @controls = new PlayerTownControlsView(this)
      @modal = new TownModal(this)
      @modal.bind_open_handler([@view.element, @controls.open])


class Building
  constructor: (key, building) ->
    @id = key
    @name = building['@name']
    @status = building['@status']
    @ttb_string = building['@ttb_string']
    @cost_res = building['@cost_res']
    @card = new BuildingCard(this)

  update: (building) ->
    @status = building['@status']
    @ttb_string = building['@ttb_string']
    @card.update(this)


class TownInventoryItem
  constructor: (key, count) ->
    @id = key
    @count = count
    @view = new TownInventoryItemView(this)

  update: (count) ->
    if @count != count
      @count = count
      @view.update(this)


class OtherPlayerTown extends Town
  constructor: (unit) ->
    super unit

  create_view: () ->
    if !@dead
      @view = new OtherPlayerTownView(this)


window.UnitFactory = (unit_hash, is_user_unit) ->
  switch unit_hash.type
    when "company"
      if is_user_unit
        unit = new PlayerCompany unit_hash
      else
        unit = new OtherPlayerCompany unit_hash
    when "green_orb" then unit = new GreenOrb unit_hash
    when "black_orb" then unit = new BlackOrb unit_hash
    when "town"
      if is_user_unit
        unit = new PlayerTown unit_hash
      else
        unit = new OtherPlayerTown unit_hash
    else
      throw new Error 'Unit have no type'
  unit
