##
# Unit inventory in controls block
# and town
# @element - DOMElement, container for inventory items
class InventoryObserver
  # max_slots may be set by model, more unit lvl - more slots, unclear for now
  constructor: (target, inventory) ->
    @target = target
    @inventory = inventory
    @resources_el = @target.find('.resources')
    @inventory_item_description_el = @target.children('.item-description')
    @max_slots = 5
    @descriptionShown = false
    # res -> $slot
    @res_el = {}
    @create_slots(@inventory)
    @bind()

  bind: () ->
    _this = this
    selected = 'inventory'
    @inventory_tab = @target.find('.tab').click(() ->
      _this.target.find('.tab').removeClass('selected')
      $(this).addClass('selected')
      _this.target.removeClass(selected)
      selected = $(this).data('tab')
      _this.target.addClass(selected)
    )

  calc_empty_slots_to_hide: (inventory) ->
    empty_slots_to_hide = 0
    for res, q of inventory
      @res_el[res] = @add_res(res, q)
      if q
        empty_slots_to_hide++
      else
        @res_el[res].hide()
    empty_slots_to_hide

  create_slots: (inventory) ->
    empty_slots_to_hide = @calc_empty_slots_to_hide(inventory)
    @add_empty_res() for [@max_slots...0]
    @hide_empty_slot() for [empty_slots_to_hide...0]

  hide_empty_slot: () ->
    @resources_el.find('.inventory-item-empty:not(.hidden)').first().addClass('hidden')

  ##
  # Update
  # @param {array} inventory - unit inventory
  update: (inventory) ->
    for res, q of inventory
      if @inventory[res] > 0 && q == 0
        @res_el[res].hide()
        @resources_el.find('.hidden').first().removeClass('hidden')
      else if inventory[res] == 0 && q > 0
        @res_el[res].show()
        @resources_el.find('.inventory-item-empty:not(.hidden)').first().addClass('hidden')
      if @inventory[res] != q
        @update_res(res, q)
    if @descriptionShown
      @inventory_item_description_el.html('')
      @descriptionShown = false

  ##
  # @param {string} res
  # @param {int} q
  add_res: (res, q) ->
    $(document.createElement('div'))
      .append(
        $(document.createElement('div'))
          .addClass('resource-q')
          .html(q),
        $(document.createElement('input'))
          .attr('type', 'text')
          .addClass('resource-input')
      )
      .attr('title', App.resource_info[res].title + ' ' + q)
      .addClass('inventory-item')
      .addClass('resource')
      .addClass(res)
      .appendTo(@resources_el)
      .click((e) =>
        @inventory_item_description_el.html(App.resource_info[res].description)
        if App.resource_info[res].action
          $(document.createElement('button'))
            .addClass('unit-inventory-item-action')
            .html(App.resource_info[res].action_label)
            .appendTo(@inventory_item_description_el)
            .click(() ->
              App.controls.actions.settle_town_action.callback()
            )
        @descriptionShown = true
      )

  add_empty_res: () ->
    $(document.createElement('div'))
      .addClass('inventory-item')
      .addClass('resource')
      .addClass('inventory-item-empty')
      .appendTo(@resources_el)

  ##
  # @param {string} res - resource name
  # @param {int} q - resource quantity
  update_res: (res, q) ->
    @res_el[res]
      .attr('title', App.resource_info[res].title + ' ' + q)
      .find('.resource-q').html(q)

window.InventoryObserver = InventoryObserver
