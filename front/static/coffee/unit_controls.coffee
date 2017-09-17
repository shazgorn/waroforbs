##
# Right column unit controls
class ControlsView
  constructor: (unit) ->
    id = unit.id
    id_attr = 'unit-info-' + id
    id_sel = '#' + id_attr
    @info = $('.unit-info-template')
        .clone()
        .appendTo('#unit-info-list')
        .removeClass('unit-info-template')
        .attr('id', id_attr)
        .data('id', id)
        .hover(
          () ->
            $("#unit-#{id}").addClass('player-unit-hover')
          ,
          () ->
            $("#unit-#{id}").removeClass('player-unit-hover')
        )
    @name = @info.find('.unit-name-info')
    @actions = @info.find('.unit-action-info')
    @life = @info.find('.unit-life-info')
    @id = @info.find('.unit-id-info')
    @life = @info.find('.unit-life-info')
    @xy = @info.find('.unit-xy-info')
    @ap = @info.find('.unit-ap-info')
    @dmg = @info.find('.unit-damage-info')
    @def = @info.find('.unit-defence-info')
    inventory = @info.find('.unit-inventory-info')
    inventory_item_description = @info.find('.unit-inventory-item-description-info')
    @dismiss = @info.find('.unit-info-dismiss')
    @dismiss.data('id', unit.id).click(() ->
      App.dismiss($(this).data('id'))
    )
    if App.active_unit_id == unit.id
      @info.addClass('active-unit-info')

    @info.off('click').on('click', () ->
      App.set_active_unit(unit.id)
    )
    @id.html(unit.id)
    @inventory_view = new InventoryView(inventory, unit.inventory, inventory_item_description)
    @update(unit)

  remove_element: () ->
    if @info
      @info.remove()
      @info = null

  update: (unit) ->
    if unit.dead
      @info.remove()
      return
    @life.html(unit.life)
    @xy.html(unit.xy)
    @ap.html(unit.ap)
    @dmg.html(unit.damage)
    @def.html(unit.defence)

class PlayerCompanyControlsView extends ControlsView
  constructor: (unit) ->
    super unit
    @name.html('C')

  update: (unit) ->
    super unit
    @life.html(unit.life)

class PlayerTownControlsView extends ControlsView
  constructor: (unit) ->
    super unit
    @name.html('T')
    @open = $(document.createElement('button'))
        .html('Open')
        .data('id', unit.id)
        .appendTo(@actions)

window.PlayerCompanyControlsView = PlayerCompanyControlsView
window.PlayerTownControlsView = PlayerTownControlsView
