##
# Unit inventory in controls block
# and town
# @element - DOMElement, container for inventory items
class InventoryObserver
  # max_slots may be set by model, more unit lvl - more slots, unclear for now
  constructor: (target, inventory, unit) ->
    @target = target
    @inventory = inventory
    @unit = unit
    @x = unit.x
    @y = unit.y
    # x,y => unit
    @adj_units = {}
    @resources_el = @target.find('.resources')
    @inventory_item_description_el = @target.children('.item-description')
    @max_slots = 5
    @descriptionShown = false
    # res -> $slot
    @res_el = {}
    @adj_cells = {}
    @adj_units_el = @target.children('.adj-units')
    @create_slots(@inventory)
    @create_adj_units()
    @bind()

  notify: (event, units) ->
    if event == 'units'
      for dy in [-1..1]
        for dx in [-1..1]
          @adj_cells[dx][dy]
            .attr('class', 'adj-unit')
            .html(@adj_unit(dx, dy))
          for unit_id, unit of units
            if unit.x == @x + dx && unit.y == @y + dy
              @adj_cells[dx][dy]
                .addClass(unit.type)
                .html('')
              # TODO: multiple units on one cell
              unless @adj_units[dx]
                @adj_units[dx] = {}
              @adj_units[dx][dy] = unit
              break

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
    @target.find('button.give').click(() =>
      if @selected_id
        to_give = {}
        to_give[res] = el.find('.resource-input').val() for res, el of @res_el
        App.give(@unit.id, @selected_id, to_give)
      else
        App.error('No selected unit')
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

  adj_unit: (dx, dy) ->
    if App.MAX_CELL_IDX >= @x + dx > 0 && App.MAX_CELL_IDX >= @y + dy > 0
      "#{@x+dx}:#{@y+dy}"
    else
      ""

  create_adj_units: () ->
    for y in [-1..1]
      adj_row = $(document.createElement('div'))
        .addClass('adj-row')
        .appendTo(@adj_units_el)
      for x in [-1..1]
        do (x, y) =>
          unless @adj_cells[x]
            @adj_units[x] = {}
            @adj_cells[x] = {}
          @adj_cells[x][y] = $(document.createElement('div'))
            .addClass('adj-unit')
            .html(@adj_unit(x, y))
            .appendTo(adj_row)
            .click(() =>
              @select_unit(x, y)
            )
          @adj_units[x][y] = null

  remove_selected: () ->
    for dy in [-1..1]
      for dx in [-1..1]
        @adj_cells[dx][dy].removeClass('selected')

  select_unit: (x, y) ->
    if @adj_units[x][y]
      @remove_selected()
      @selected_id = @adj_units[x][y].id
      @adj_cells[x][y].addClass('selected')
    else
      @selected_id = null

  update_adj_units: () ->
    for dy in [-1..1]
      for dx in [-1..1]
        @adj_cells[dx][dy]
          .html(@adj_unit(dx, dy))

  ##
  # Update
  # @param {array} inventory - unit inventory
  update: (inventory, x, y) ->
    for res, q of inventory
      if @inventory[res] > 0 && q == 0
        @res_el[res].hide()
        @resources_el.find('.hidden').first().removeClass('hidden')
      else if inventory[res] == 0 && q > 0
        @res_el[res].show()
        @resources_el.find('.inventory-item-empty:not(.hidden)').first().addClass('hidden')
      if @inventory[res] != q
        @update_res(res, q)
    if @x != x || @y != y
      @x = x
      @y = y
      @update_adj_units()
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
          .attr('name', res)
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
