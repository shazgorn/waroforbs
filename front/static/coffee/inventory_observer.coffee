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
    @adj_units_el = @target.find('.adj-units')
    @adj_units_multiple = @target.find('.adj-units-multiple')
    @create_slots(@inventory)
    @create_adj_units()
    @bind()
    # #@update_inventory(@inventory, {})

  notify: (event, units) ->
    if event == 'units'
      for dy in [-1..1]
        for dx in [-1..1]
          unless @adj_units[dx]
            @adj_units[dx] = {}
          @adj_cells[dx][dy]
            .attr('class', 'adj-unit')
            .html(@adj_unit(dx, dy))
          c = 0
          @adj_units[dx][dy] = []
          for unit_id, unit of units
            if unit.x == @x + dx && unit.y == @y + dy && (unit.own || !unit.user_id)
              c++
              @adj_cells[dx][dy]
                .addClass(unit.type)
                .attr('title', unit.title)
              if c > 1
                @adj_cells[dx][dy]
                  .css('color', 'white')
                  .html(c)
              else
                @adj_cells[dx][dy].html('')
              @adj_units[dx][dy].push unit

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
        unless @adj_cells[dx]
          @adj_cells[dx] = {}
        unless @adj_units[dx]
          @adj_units[dx] = {}
        @adj_units[dx][dy] = []
        do (dx, dy) =>
          @adj_cells[dx][dy] = $(document.createElement('div'))
            .addClass('adj-unit')
            .html(@adj_unit(dx, dy))
            .appendTo(adj_row)
            .click(() =>
              @select_unit_or_multiple(dx, dy)
              if @selected_tab == 'take'
                @update_inventory(@selected_unit.inventory, {})
            )

  remove_selected: () ->
    @target.find('.adj-units-container .selected').removeClass('selected')

  select_unit_or_multiple: (dx, dy) ->
    @remove_selected()
    @adj_units_multiple.children('*').remove()
    if @adj_units[dx][dy].length > 1
      for unit in @adj_units[dx][dy]
        do (dx, dy, unit) =>
          cell = $(document.createElement('div'))
            .attr('title', unit.title)
            .addClass('adj-unit ' + unit.type)
            .appendTo(@adj_units_multiple)
            .click(() =>
              @remove_selected()
              cell.addClass('selected')
              @selected_id = unit.id
              @selected_unit = unit
              if @selected_tab == 'take'
                @update_inventory(@selected_unit.inventory, {})
            )
    else if @adj_units[dx][dy].length == 1
      @select_unit(dx, dy)
    else
      @selected_id = null
      @selected_unit = null

  select_unit: (dx, dy) ->
    @selected_unit = @adj_units[dx][dy][0]
    @selected_id = @selected_unit.id
    @adj_cells[dx][dy].addClass('selected')

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
    all = $(document.createElement('button'))
      .addClass('resource-all')
      .html(">>")
      .click(() ->
        $(this).prev().val($(this).prev().prev().html())
      )
    $(document.createElement('div'))
      .append(
        $(document.createElement('div'))
          .addClass('resource-ico ' + res)
          .attr('title', App.resource_info[res].title + ' ' + q),
        @res_q[res],
        @res_input[res],
        all
      )
      .addClass('inventory-item resource')
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
