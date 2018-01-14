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
        .addClass 'unit appear-animation'
        .addClass(model.type)
        .data('id', model.id)
        .attr('title', @unit_title)
        .attr('id', model.attr_id)
    setTimeout(() =>
      @element
        .removeClass 'appear-animation'
      , 1000)
    if model.life
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
    else if model.user_id
      @element.addClass('enemy')

  remove_element: () ->
    if @element
      @element
        .addClass 'disappear-animation'
      setTimeout(() =>
        @element.remove()
        @element = null
      , 1000)


  update: (model) ->
    if model.life
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

window.BlackOrbView = BlackOrbView
window.GreenOrbView = GreenOrbView
window.MonolithView = MonolithView
window.UnitView = UnitView
