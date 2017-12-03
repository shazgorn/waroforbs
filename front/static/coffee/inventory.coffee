##
# Unit inventory in controls block
# and town
# @element - DOMElement, container for inventory items
class InventoryView
  # max_slots may be set by model, more unit lvl - more slots, unclear for now
  constructor: (@element, @inventory_item_description) ->
    @max_slots = 5
    @descriptionShown = false
    @res_el = {}

  calc_empty_slots_to_hide: (new_inventory) ->
    empty_slots_to_hide = 0
    for res, q of new_inventory
      @res_el[res] = @add_res(res, q)
      if q
        empty_slots_to_hide++
      else
        @res_el[res].hide()
    empty_slots_to_hide

  create_slots: (new_inventory) ->
    empty_slots_to_hide = @calc_empty_slots_to_hide(new_inventory)
    @add_empty_res() for [@max_slots...0]
    @hide_empty_slot() for [empty_slots_to_hide...0]

  hide_empty_slot: () ->
    @element.find('.inventory-item-empty:not(.hidden)').first().addClass('hidden')

  ##
  # Update
  # @param {array} old_inventory - inventory in model
  # @param {array} new_inventory - unit inventory
  sync_resources: (old_inventory, new_inventory) ->
    for res, q of new_inventory
      if old_inventory[res] > 0 && q == 0
        @res_el[res].hide()
        @element.find('.hidden').first().removeClass('hidden')
      else if old_inventory[res] == 0 && q > 0
        @res_el[res].show()
        @element.find('.inventory-item-empty:not(.hidden)').first().addClass('hidden')
      if old_inventory[res] != q
        @update_res(res, q)
    if @descriptionShown
      @inventory_item_description.html('')
      @descriptionShown = false

  ##
  # @param {string} res
  # @param {int} q
  add_res: (res, q) ->
    $(document.createElement('div'))
      .html(
        $(document.createElement('div'))
          .addClass('inventory-item-q')
          .html(q)
      )
      .attr('title', App.resource_info[res].title + ' ' + q)
      .addClass('inventory-item')
      .addClass('inventory-item-' + res)
      .appendTo(@element)
      .click((e) =>
        e.preventDefault()
        @inventory_item_description.html(App.resource_info[res].description)
        if App.resource_info[res].action
          $(document.createElement('button'))
            .addClass('unit-inventory-item-action')
            .html(App.resource_info[res].action_label)
            .appendTo(@inventory_item_description)
            .click(() ->
              App.controls.actions.settle_town_action.callback()
            )
        @descriptionShown = true
      )

  add_empty_res: () ->
    $(document.createElement('div'))
      .addClass('inventory-item')
      .addClass('inventory-item-empty')
      .appendTo(@element)

  ##
  # @param {string} res - resource name
  # @param {int} q - resource quantity
  update_res: (res, q) ->
    @element
      .find('.inventory-item-' + res)
      .attr('title', App.resource_info[res].title + ' ' + q)
      .find('.inventory-item-q').html(q)

window.InventoryView = InventoryView
