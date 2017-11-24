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
    @buildings = {}
    @buildings_cards = {}
    for key, building of unit.buildings
      @buildings[key] = new Building(key, building)

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
    @workers = unit.workers
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
      for key, building of @buildings
        @buildings_cards[key] = BuildingCard.create(building)
      for key, building_card of @buildings_cards
        @modal.append_building_card_el(building_card.el)
        building_card.set_town_modal(@modal, @buildings[key])
      @modal.create_province()
      # @modal.init_town_workers(@workers)
      @modal.bind_open_handler([@view.element])

  update_modal: () ->
    if @modal
      @modal.update()
      @modal.update_province()

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
