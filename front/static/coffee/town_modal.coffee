##
# Create town modal
# and fill it with buildings, inventory, quick actions
# This class will replace TownControls because of bad naming and coding
class TownModal
  constructor: (town) ->
    @modal_town = $('.modal.town')
    @controls = new TownModalControls
    @inventory_view = new TownInventoryView(@modal_town.find('.town-inventory-inner'), town.inventory)
    for key, building of town.buildings
      @modal_town.find('.buildings-inner').append(building.card.el)
      @controls.init_building building

  bind_open_handler: (list) ->
    for el in list
      el.click () =>
        @modal_town.show()

  update: (town) ->
    return

window.TownModal = TownModal
