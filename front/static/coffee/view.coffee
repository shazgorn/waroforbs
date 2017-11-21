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
        .addClass(model.css_class)
        .data('id', model.id)
        .attr('title', model.title)
        .attr('id', model.attr_id)
    @life_el = $(document.createElement('span'))
        .html(model.life)
        .appendTo(@element)

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

##
#  TODO: write sane tests
class SquadView extends UnitView
  constructor: (model) ->
    super model

class PlayerSquadView extends SquadView
  constructor: (model) ->
    super model
    @life_el.addClass('player-unit-life-info')
    @element
      .addClass('select-target')
      .on('click', () =>
        App.set_active_unit(model.id)
      )

class OtherPlayerSquadView extends SquadView
  constructor: (model) ->
    super model
    @life_el.addClass('other-player-unit-life-info')

class OrbView extends UnitView
  constructor: (model) ->
    super model

class BlackOrbView extends OrbView
  constructor: (model) ->
    super model

class GreenOrbView extends OrbView
  constructor: (model) ->
    super model

class PlayerTownView extends UnitView
  constructor: (model) ->
    super model
    @life_el.addClass('player-unit-life-info')
    @element
      .addClass 'select-target'
      .on('click', () =>
        App.set_active_unit(model.id)
      )

class OtherPlayerTownView extends UnitView
  constructor: (model) ->
    super model
    @life_el.addClass('other-player-unit-life-info')


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
      .addClass('inventory-res-' + item.id)
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
window.PlayerSquadView = PlayerSquadView
window.OtherPlayerSquadView = OtherPlayerSquadView
window.PlayerTownView = PlayerTownView
window.OtherPlayerTownView = OtherPlayerTownView
window.BlackOrbView = BlackOrbView
window.GreenOrbView = GreenOrbView
