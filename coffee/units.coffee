# rename 'css_' to 'attr_'
class Unit
  constructor: (unit) ->
    @_unit = unit
    @id = unit['@id']
    @attr_id = "unit-#{@id}"
    @x = unit['@x']
    @y = unit['@y']
    @type = unit['@type']
    @damage = unit['@damage']
    @defence = unit['@defence']

  # to call after unit initialization
  init: () ->
    return

class Company extends Unit
  constructor: (unit) ->
    super unit
    @title = unit['@user_name'] + '(' + unit['@hp'] + ')'

class PlayerCompany extends Company
  constructor: (unit) ->
    super unit
    @css_class = 'player-unit player-hero'
    @squads = unit['@squads']
    @hp = unit['@hp']
    @ap = unit['@ap']

class OtherPlayerCompany extends Company
  constructor: (unit) ->
    super unit
    @css_class = 'other-player-hero'

class GreenOrb extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'green-orb'
    @title = unit['@hp']
    if unit['@hp'] < 50
      @css_class += ' orb-sm'
    else if unit['@hp'] < 100
      @css_class += ' orb-md'
    else
      @css_class += ' orb'

class BlackOrb extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'black-orb'
    @title = unit['@hp']
    if unit['@hp'] < 500
      @css_class += ' orb-sm'
    else if unit['@hp'] < 700
      @css_class += ' orb-md'
    else
      @css_class += ' orb'

class Town extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'town'
    @title = unit['@user_name'] + ' Town'

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
    # id => cell
    @cells = {}
    range = [(-1 * App.TOWN_RADIUS)..App.TOWN_RADIUS]
    for dy in range
      for dx in range
        x = @x + dx
        y = @y + dy
        id = "#{x}_#{y}"
        if App.cells[id]
          cell = new TownCell(id, x, y, @id)
          if @x == x && @y == y
            cell.html = cell.title = cell.type = 'town'
          else
            cell.set_type(App.cells[id]['@type'])
        else
          cell = new TownCell(id, null, null, @id)
          cell.html = '&nbsp;'
          cell.title = 'Hic sunt dracones'
        @cells[id] = cell
    @workers = unit['@workers']
    for id, w of @workers
      if w['@x'] && w['@y']
        @cells[w['@x'] + '_' + w['@y']].has_worker = true

  init: () ->
    App.init_town_buildings(@_unit['@buildings'])
    App.init_town_controls(@_unit['@actions'])
    App.init_town_workers(this)
    App.init_town_inventory(@_unit['@inventory'])

class OtherPlayerTown extends Town
  constructor: (unit) ->
    super unit

UnitFactory = (unit_hash, user_id) ->
  throw new Error 'Unit is not set on map' if !unit_hash['@x']? || !unit_hash['@y']?
  if unit_hash?
    switch unit_hash['@type']
      when "company"
        if unit_hash['@user_id']
          if unit_hash['@user_id'] == user_id
            unit = new PlayerCompany unit_hash
          else unit = new OtherPlayerCompany unit_hash
      when "orb" then unit = new GreenOrb unit_hash
      when "black_orb" then unit = new BlackOrb unit_hash
      when "town"
        if unit_hash['@user_id']
          if unit_hash['@user_id'] == user_id
            unit = new PlayerTown unit_hash
          else
            unit = new OtherPlayerTown unit_hash
      else throw new Error 'Unit have no type'
  unit

window.UnitFactory = UnitFactory
