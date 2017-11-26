##
# Create town modal
# and fill it with buildings, inventory, quick actions
class TownModal
  ##
  # @constructor
  # @param {PlayerTown} town
  constructor: (town) ->
    @el = $('.modal.town')
    @el.find('.close-modal').click(() ->
      $('.modal').hide()
    )
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

  create_province: (workers, town_x, town_y, town_id, town_title) ->
    @province = new Province(workers, town_x, town_y, town_id, town_title)
    @province.draw_town_cells()
    @province.draw_workers()
    @province.bind_actions_cells()

  update_province: (workers, town_title) ->
    @province.update(workers, town_title)

  clean_up: () ->
    @el.find('.buildings-inner *').remove()
    @el.find('.modal-building-actions-inner *').remove()
    @el.find('.town-inventory-inner *').remove()

  restore_title: () ->
    $('.modal.town .modal-title').html(@name)

window.TownModal = TownModal
