##
# Right column unit controls
class UnitControls
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
    @attack = @info.find('.unit-attack-info')
    @def = @info.find('.unit-defence-info')
    @disband = @info.find('.unit-info-disband')
    @disband.data('id', unit.id).click(() ->
      App.disband($(this).data('id'))
    )
    if App.active_unit_id == unit.id
      @info.addClass('active-unit-info')

    @info.off('click').on('click', () ->
      App.set_active_unit(unit.id)
    )
    @inventory_observer = new InventoryObserver(@info.find('.unit-inventory'), unit.inventory, unit)
    ObserverRegistry.add('inventory_observer_' + unit.id, @inventory_observer)
    @id.html(unit.id)
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
            new_name = input.val()
            @name.html(new_name)
            @rename(unit.id, new_name)
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

  update: (unit) ->
    if unit.dead && @info
      @info.remove()
      return
    if unit.name != @unit_name
      @unit_name = unit.name
      @name.attr('title', @unit_name)
      @name.html(@unit_name)
    @inventory_observer.update(unit.inventory, unit.x, unit.y)
    @life.html(unit.life)
    @wounds.html(unit.wounds)
    @xy.html(unit.x + ',' + unit.y)
    @ap.html(unit.ap)
    @attack.html(unit.attack)
    @def.html(unit.defence)

  remove_element: () ->
    if @info
      @info.remove()
      @info = null

  rename: (unit_id, new_name) ->
    App.rename_unit(unit_id, new_name)

window.UnitControls = UnitControls
