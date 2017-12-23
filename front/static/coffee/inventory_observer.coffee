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
    @res_q = {}
    @res_input = {}
    @adj_cells = {}
    @adj_units_el = @target.children('.adj-units')
    @create_slots(@inventory)
    @create_adj_units()
    @bind()
    # #@update_inventory(@inventory, {})

  notify: (event, units) ->
    if event == 'units'
      for dy in [-1..1]
        for dx in [-1..1]
          @adj_cells[dx][dy]
            .attr('class', 'adj-unit')
            .html(@adj_unit(dx, dy))
          for unit_id, unit of units
            if unit.x == @x + dx && unit.y == @y + dy && unit.own
              @adj_cells[dx][dy]
                .addClass(unit.type)
                .attr('title', unit.title)
                .html('')
              # TODO: multiple units on one cell
              unless @adj_units[dx]
                @adj_units[dx] = {}
              @adj_units[dx][dy] = unit
              break

  bind: () ->
    _this = this
    @selected_tab = 'inventory'
    @inventory_tab = @target.find('.tab').click(() ->
      _this.target.find('.tab').removeClass('selected')
      $(this).addClass('selected')
      _this.target.removeClass(_this.selected_tab)
      _this.selected_tab = $(this).data('tab')
      _this.target.addClass(_this.selected_tab)
      if _this.selected_tab in ['inventory', 'give']
        _this.update_inventory(_this.inventory, {})
      _this.selected_id = null
    )
    @target.find('button.give').click(() =>
      if @selected_id
        App.give(@unit.id, @selected_id, @collect_inv_from_inputs())
      else
        App.error('No selected unit')
    )
    @target.find('button.take').click(() =>
      if @selected_id
        App.take(@unit.id, @selected_id, @collect_inv_from_inputs())
      else
        App.error('No selected unit')
    )

  collect_inv_from_inputs: () ->
    inv = {}
    for res, el of @res_el
      input = el.find('.resource-input')
      inv[res] = input.val()
      input.val('')
    inv

  create_slots: (inventory) ->
    for res, q of inventory
      @res_el[res] = @add_res(res, q)

  adj_unit: (dx, dy) ->
    if App.MAX_CELL_IDX >= @x + dx > 0 && App.MAX_CELL_IDX >= @y + dy > 0
      "#{@x+dx}:#{@y+dy}"
    else
      ""

  create_adj_units: () ->
    for dy in [-1..1]
      adj_row = $(document.createElement('div'))
        .addClass('adj-row')
        .appendTo(@adj_units_el)
      for dx in [-1..1]
        do (dx, dy) =>
          unless @adj_cells[dx]
            @adj_units[dx] = {}
            @adj_cells[dx] = {}
          @adj_cells[dx][dy] = $(document.createElement('div'))
            .addClass('adj-unit')
            .html(@adj_unit(dx, dy))
            .appendTo(adj_row)
            .click(() =>
              @select_unit(dx, dy)
              if @selected_tab == 'take'
                @update_inventory(@adj_units[dx][dy].inventory, {})
            )
          @adj_units[dx][dy] = null

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

  update_inventory: (new_inventory, current_inventory) ->
    for res, q of new_inventory
      if !q
        @res_el[res].hide()
      else if q > 0
        @res_el[res].show()
      if current_inventory[res] != q
        @update_res(res, q)

  ##
  # Update
  # @param {array} inventory - unit inventory
  update: (inventory, x, y) ->
    @update_inventory(inventory, @inventory)
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
    @res_q[res] = $(document.createElement('div'))
      .addClass('resource-q')
      .html(q)
    @res_input[res] = $(document.createElement('input'))
      .attr('type', 'text')
      .attr('name', res)
      .addClass('resource-input')
    $(document.createElement('div'))
      .append(
        @res_q[res],
        @res_input[res]
      )
      .attr('title', App.resource_info[res].title + ' ' + q)
      .addClass('inventory-item resource ' + res)
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

  ##
  # @param {string} res - resource name
  # @param {int} q - resource quantity
  update_res: (res, q) ->
    @res_el[res]
      .attr('title', App.resource_info[res].title + ' ' + q)
    @res_q[res]
      .html(q)

window.InventoryObserver = InventoryObserver
