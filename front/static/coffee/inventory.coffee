##
# Unit inventory in controls block
# and town
# inventoryEl - container for inventory items
class InventoryView
  constructor: (@inventoryEl, new_inventory) ->
    filled_slots = 0
    for res, q of new_inventory
      @create_res(res, q) if q
      filled_slots++ if q > 0
    for f in [filled_slots+1..5]
      @create_empty_res()

  ##  
  # Update
  # old_inventory - inventory in model
  # new_inventory - unit inventory
  sync_resources: (old_inventory, new_inventory) ->
    empty_res_to_add = 0
    max_slots = 5
    console.log(old_inventory);
    console.log(new_inventory);
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
      .appendTo(@inventoryEl)
      .click((e) =>
        e.preventDefault();
        @inventory_item_description.html(App.resource_info[res].description)
        if App.resource_info[res].action
          $(document.createElement('button'))
            .html(App.resource_info[res].action_label)
            .appendTo(@inventory_item_description)
            .click(() ->
              console.log('settle the town')
              App.controls.actions.settle_town_action.callback()
            )
        @descriptionShown = true
      )

  create_empty_res: () ->
    $(document.createElement('div'))
      .addClass('inventory-item')
      .addClass('inventory-item-empty')
      .appendTo(@inventoryEl)

  ##
  # res - resource name
  remove_res: (res) ->
    @inventoryEl.children('.inventory-item-' + res).remove()

  ##
  # res - resource name
  # q - resource quantity
  update_res: (res, q) ->
    @inventoryEl.find('.inventory-item-' + res + ' .inventory-item-q').html(q)

window.InventoryView = InventoryView
