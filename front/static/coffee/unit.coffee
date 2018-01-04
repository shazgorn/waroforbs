##
# unit title - title attribute for unit's element on the map, building title is another thing
# Every unit should have every property no matter player's or not
# till visibility options arrive
# modal - TownModal
# @param {object} unit
# @param {bool} @own
class Unit
  constructor: (unit, @own) ->
    @_unit = unit
    @id = unit.id
    @attr_id = "unit-#{@id}"
    @type = unit.type
    @attack = unit.attack
    @defence = unit.defence
    @dead = unit.dead
    @inventory =  unit.inventory
    @user_id = unit.user_id
    @user_name = unit.user_name
    if !@dead
      @need_to_move = true
    @set_title_from(unit)
    @buildings = {}
    @buildings_cards = {}
    for key, building of unit.buildings
      @buildings[key] = new Building(key, building)
    if unit.radius?
      @radius = unit.radius

  set_title_from: (unit) ->
    @title = unit.name
    if not @own and unit.user_name
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
    @set_title_from unit
    @need_to_move = (@x != unit.x || @y != unit.y)
    @x = unit.x
    @y = unit.y
    @ap = unit.ap
    @life = unit.life
    @wounds = unit.wounds
    @name = unit.name
    @workers = unit.workers
    @inventory = unit.inventory

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
      for key, building of @buildings
        @buildings_cards[key] = BuildingCard.create(building)
      for key, building_card of @buildings_cards
        @modal.append_building_card_el(building_card.el)
        building_card.set_town_modal(@modal, @buildings[key])
      @modal.create_province(@workers, @x, @y, @id, @title, @radius)
      @modal.bind_open_handler([@view.element])

  update_modal: () ->
    if @modal
      @modal.update(this)
      @modal.update_province(@workers, @title)

  remove: () ->
    if @view
      @view.remove_element()
    if @controls
      @controls.remove_element()
    if @modal
      @modal.clean_up()

  update_buildings: (unit) ->
    for key, building of @buildings
      building.update(unit.buildings[key])
    for key, building_card of @buildings_cards
      building_card.update(unit.buildings[key])

window.Unit = Unit
