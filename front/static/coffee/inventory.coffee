##
# Unit inventory in controls block
# and town
# @element - DOMElement, container for inventory items
class InventoryView
  # max_slots may be set by model, more unit lvl - more slots, unclear for now
  constructor: (@element, new_inventory, @inventory_item_description) ->
    @max_slots = 5
    @descriptionShown = false
    filled_slots = 0
    for res, q of new_inventory
      @create_res(res, q) if q
      filled_slots++ if q > 0
    for f in [filled_slots+1..@max_slots]
      @create_empty_res()

  ##
  # Update
  # @param {array} old_inventory - inventory in model
  # @param {array} new_inventory - unit inventory
  sync_resources: (old_inventory, new_inventory) ->
    empty_res_to_add = 0
    for res, q of new_inventory
      if old_inventory[res] > 0 && q == 0
        @remove_res(res)
        empty_res_to_add++
      else if old_inventory[res] == 0 && q > 0
        @create_res(res, q)
        empty_res_to_add--
      else if old_inventory[res] != q
        @update_res(res, q)
    if empty_res_to_add
      for empty in [0...empty_res_to_add]
        @create_empty_res()
    if @descriptionShown
      @inventory_item_description.html('')
      @descriptionShown = false

  ##
  # @param {string} res
  # @param {int} q
  create_res: (res, q) ->
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
        e.preventDefault();
        @inventory_item_description.html(App.resource_info[res].description)
        if App.resource_info[res].action
          $(document.createElement('button'))
            .addClass('unit-inventory-item-action')
            .html(App.resource_info[res].action_label)
            .appendTo(@inventory_item_description)
            .click(() ->
              console.log('settle the town')
              App.controls.actions.settle_town_action.callback()
            )
        @descriptionShown = true
      )

  create_empty_res: ->
    $(document.createElement('div'))
      .addClass('inventory-item')
      .addClass('inventory-item-empty')
      .appendTo(@element)

  ##
  # @param {string} res - resource name
  remove_res: (res) ->
    @element.children('.inventory-item-' + res).remove()

  ##
  # @param {string} res - resource name
  # @param {int} q - resource quantity
  update_res: (res, q) ->
    @element
      .find('.inventory-item-' + res)
      .attr('title', App.resource_info[res].title + ' ' + q)
      .find('.inventory-item-q').html(q)

class TownInventoryView extends InventoryView
  constructor: (element, new_inventory, inventory_item_description) ->
    super(element, new_inventory, inventory_item_description)
    @max_slots = 10

window.InventoryView = InventoryView
window.TownInventoryView = TownInventoryView
