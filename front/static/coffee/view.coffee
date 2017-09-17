class View
  constructor: () ->
    # jQuery element object
    @element = null

class UnitView extends View
  constructor: (unit_model) ->
    @element = $(document.createElement('div'))
        .addClass('unit')
        .addClass(unit_model.css_class)
        .data('id', unit_model.id)
        .attr('title', unit_model.title)
        .attr('id', unit_model.attr_id)

  update_element: (unit_model) ->
    # update title, because it contains hp and must be updated 'every' time
    if unit_model.title
      @element.attr('title', unit_model.title)

  remove_element: () ->
    if @element
      @element.remove()
      @element = null
  
  update_title: () ->
    return
  
class CompanyView extends UnitView
  constructor: (unit_model) ->
    super unit_model
    @life_el = $(document.createElement('span'))
        .html(unit_model.life)
        .appendTo(@element)

  set_life: (life) ->
    @life_el.html(life)

class PlayerCompanyView extends CompanyView
  constructor: (unit_model) ->
    super unit_model
    @life_el.addClass('player-unit-life-info')
    @element
      .addClass('select-target')
      .on('click', () =>
        App.set_active_unit(unit_model.id)
      )

class OtherPlayerCompanyView extends CompanyView
  constructor: (unit_model) ->
    super unit_model
    @life_el.addClass('other-player-unit-life-info')

class OrbView extends UnitView
  constructor: (unit_model) ->
    super unit_model

class BlackOrbView extends OrbView
  constructor: (unit_model) ->
    super unit_model

class GreenOrbView extends OrbView
  constructor: (unit_model) ->
    super unit_model

class PlayerTownView extends UnitView
  constructor: (unit_model) ->
    super unit_model
    @element
      .addClass 'select-target'
      .on('click', () =>
        App.set_active_unit(unit_model.id)
      )

class OtherPlayerTownView extends UnitView
  constructor: (unit_model) ->
    super unit_model


class TownInventoryItemView extends View
  ###
  # @param {TownInventoryItem} item
  ###
  constructor: (item) ->
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
window.PlayerCompanyView = PlayerCompanyView
window.OtherPlayerCompanyView = OtherPlayerCompanyView
window.PlayerTownView = PlayerTownView
window.OtherPlayerTownView = OtherPlayerTownView
window.BlackOrbView = BlackOrbView
window.GreenOrbView = GreenOrbView
