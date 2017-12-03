class View
  constructor: (model) ->
    # jQuery element object
    @element = null

# update title, because it contains hp and must be updated 'every' time
class UnitView extends View
  constructor: (model) ->
    super(model)
    @unit_title = model.title
    @unit_life = model.life
    @element = $(document.createElement('div'))
        .addClass('unit')
        .addClass(model.type)
        .data('id', model.id)
        .attr('title', model.title)
        .attr('id', model.attr_id)
    @life_el = $(document.createElement('span'))
        .html(model.life)
        .addClass('life-box')
        .appendTo(@element)
    if model.own
      @element
        .addClass('own')
        .addClass('select-target')
        .on('click', () =>
          App.set_active_unit(model.id)
        )
    else
      @element.addClass('enemy')

  remove_element: () ->
    if @element
      @element.remove()
      @element = null

  update: (model) ->
    if @unit_life != model.life
      @unit_life = model.life
      @life_el.html(@unit_life)
    if @unit_title != model.title
      @unit_title = model.title
      @element.attr('title', @unit_title)


class OrbView extends UnitView
  constructor: (model) ->
    super model

class BlackOrbView extends OrbView
  constructor: (model) ->
    super model

class GreenOrbView extends OrbView
  constructor: (model) ->
    super model

class MonolithView extends UnitView
  constructor: (model) ->
    super model


class TownInventoryItemView extends View
  ###
  # @param {TownInventoryItem} item
  ###
  constructor: (item) ->
    super(item)
    if item.count
      @create_view(item)

  create_view: (item) ->
    @el = $(document.createElement('div'))
      .addClass('inventory-res')
      .addClass(item.id)
      .attr('title', item.id + ' ' + item.count)
      .html(item.count)
      .appendTo('.town-inventory-inner')

  update: (item) ->
    if !@el && item.count
      create_view(item)
    else if @el
      if item.count
        @el.html(item.count)
      else
        @el.remove()
        @el = null

window.TownInventoryItemView = TownInventoryItemView
window.BlackOrbView = BlackOrbView
window.GreenOrbView = GreenOrbView
window.MonolithView = MonolithView
window.UnitView = UnitView
