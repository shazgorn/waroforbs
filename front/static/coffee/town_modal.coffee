##
# Create town modal
# and fill it with buildings, inventory, quick actions
# This class will replace TownControls because of bad naming and coding
class TownModal
  ##
  # @constructor
  # @param {PlayerTown} town
  constructor: (town) ->
    @el = $('.modal.town')
    # towns name, will be set by player someday
    @name = town.name
    @el.find('.modal-title').html(@name)
    inventory_item_description = @el.find('.town-inventory-item-description')
    @inventory_view = new TownInventoryView(@el.find('.town-inventory-inner'), town.inventory, inventory_item_description)

  append_building_card_el: (el) ->
    @el.find('.buildings-inner').append(el)

  ##
  # Open the town modal window by clicking on any element in the 'list'
  # @param {array} list - of town unit on the map and maybe 'quick open town' buttons
  bind_open_handler: (list) ->
    for el in list
      el.click () =>
        @el.show()

  update: (town) ->
    if town.name != @name
      @title = town.title
      @el.find('.modal-title').html(@name)

  create_province: () ->
    @controls = new Province

  update_province: () ->
    @controls.update()

  clean_up: () ->
    @el.find('.buildings-inner *').remove()
    @el.find('.modal-building-actions-inner *').remove()
    @el.find('.town-inventory-inner *').remove()

  restore_title: () ->
    $('.modal.town .modal-title').html(@name)

window.TownModal = TownModal
