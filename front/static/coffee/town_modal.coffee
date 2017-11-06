##
# Create town modal
# and fill it with buildings, inventory, quick actions
# This class will replace TownControls because of bad naming and coding
class TownModal
  ##
  # @constructor
  # @param {PlayerTown} town
  constructor: (town) ->
    @modal_town = $('.modal.town')
    @controls = new TownModalControls
    inventory_item_description = @modal_town.find('.town-inventory-item-description')
    @inventory_view = new TownInventoryView(@modal_town.find('.town-inventory-inner'), town.inventory, inventory_item_description)
    for key, building of town.buildings
      @modal_town.find('.buildings-inner').append(building.card.el)

  ##
  # Open the town modal window by clicking on any element in the 'list'
  # @param {array} list - of town unit on the map and maybe 'quick open town' buttons
  bind_open_handler: (list) ->
    for el in list
      el.click () =>
        @modal_town.show()

  update: (town) ->
    return

window.TownModal = TownModal
