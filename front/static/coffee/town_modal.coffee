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
    @modal_title = @el.find('.modal-title')
    @modal_title.html(@name)
    inventory_item_description = @el.find('.town-inventory-item-description')
    @inventory_view = new InventoryView(@el.find('.town-inventory-inner'), inventory_item_description)
    @inventory_view.create_slots(town.inventory)
    @building_description = $('#building-description')
    @buildings_inner = @el.find('#buildings-inner')
    @buildings_inner
      .addClass('build-mode-off')
    $('#build-mode-on').click(() =>
      @close_building()
      @buildings_inner
        .removeClass('build-mode-off')
        .addClass('build-mode-on')
    )
    $('#build-mode-off').click(() =>
      @close_building()
      @buildings_inner
        .addClass('build-mode-off')
        .removeClass('build-mode-on')
    )

  append_building_card_el: (el) ->
    el
    #@el.find('.buildings-list').append(el)

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
      @modal_title.html(@name)

  create_province: (workers, town_x, town_y, town_id, town_title, town_radius) ->
    @province = new Province(workers, town_x, town_y, town_id, town_title, town_radius)
    @province.draw_town_cells()
    @province.draw_workers()
    @province.bind_actions_cells()

  update_province: (workers, town_title) ->
    @province.update(workers, town_title)

  clean_up: () ->
    @el.find('.buildings-list *').remove()
    @el.find('.modal-building-actions-inner *').remove()
    @el.find('.town-inventory-inner *').remove()
    @el.find('.province-inner *').remove()
    @el.find('.workers-list *').remove()

  remove_building_inner: () ->
    $('.modal-body .modal-building-inner *').remove()
    $('.modal-body .modal-building-actions-inner *').remove()

  close_building: () ->
    @remove_building_inner()
    @restore_title()
    @building_description.html('')

  append_title: (title) ->
    @modal_title.html(@name + ' - ' + title)

  restore_title: () ->
    @modal_title.html(@name)

  set_building_description: (name) ->
    @building_description.html(App.building_descriptions[name])


window.TownModal = TownModal
