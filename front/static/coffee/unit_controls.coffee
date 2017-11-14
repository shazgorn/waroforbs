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
    @name_text = unit.name
    @actions = @info.find('.unit-action-info')
    @life = @info.find('.unit-life-info')
    @id = @info.find('.unit-id-info')
    @life = @info.find('.unit-life-info')
    @wounds = @info.find('.unit-wounds-info')
    @xy = @info.find('.unit-xy-info')
    @ap = @info.find('.unit-ap-info')
    @dmg = @info.find('.unit-damage-info')
    @def = @info.find('.unit-defence-info')
    inventory = @info.find('.unit-inventory-info')
    inventory_item_description = @info.find('.unit-inventory-item-description-info')
    @disband = @info.find('.unit-info-disband')
    @disband.data('id', unit.id).click(() ->
      App.disband($(this).data('id'))
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
    if unit.name != @unit_name
      @unit_name = unit.name
      @name.attr('title', @unit_name)
      @name.html(@unit_name)
    @life.html(unit.life)
    @wounds.html(unit.wounds)
    @xy.html(unit.x + ',' + unit.y)
    @ap.html(unit.ap)
    @dmg.html(unit.damage)
    @def.html(unit.defence)

class PlayerControlsView extends ControlsView
  rename: (unit_id, new_name) ->
    App.rename_unit(unit_id, new_name)

  constructor: (unit) ->
    super unit
    @name.html(unit.name)
    @name.dblclick(() =>
      @name.html('')
      @name.append(
        input = $(document.createElement('input'))
          .attr('type', 'text')
          .addClass('text')
          .css('width', '160px')
          .css('height', '16px') # 20px - 4px
          .css('float', 'left')
          .attr('name', 'edit-unit-name')
          .attr('id', 'edit-unit-name')
          .prop('readonly', false)
          .val(unit.name)
      )
      input
        .focus()
        .keypress((e) =>
          if e.which == 13
            @rename(unit.id, input.val())
        )
      @name.append(
        $(document.createElement('button'))
          .addClass('ok-button')
          .html('')
          .click(() =>
            @rename(unit.id, input.val())
          )
      )
      @name.append(
        $(document.createElement('button'))
          .addClass('cancel-button')
          .html('')
          .click(() =>
            @name.html(unit.name)
          )
      )
    )
    @name.attr('title', unit.name)

class PlayerSquadControlsView extends PlayerControlsView
  constructor: (unit) ->
    super unit

class PlayerTownControlsView extends PlayerControlsView
  constructor: (unit) ->
    super unit


window.PlayerSquadControlsView = PlayerSquadControlsView
window.PlayerTownControlsView = PlayerTownControlsView
