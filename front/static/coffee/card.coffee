##
# There can be more cards(for units) but for now it is just building`s base class
# Unit card
##
# Card - some entity in modal window
# In this case it is building box in the town screen
# Created when new building model is fetched, updated when building model has been changed, etc
# Call town modal controls via model.controls
#
# TODO: Add close button

class BuildingCard
  @create: (building) ->
    switch building.name
      when 'barracs' then building = new BarracsCard(building)
      when 'tavern' then building = new TavernCard(building)
      when 'roads' then building = new RoadsCard(building)
      when 'factory' then building = new FactoryCard(building)
      when 'sawmill' then building = new SawmillCard(building)
      when 'quarry' then building = new QuarryCard(building)
      else console.error('Unknown building ' + building)

  ###
  # @param {Building} building
  ###
  constructor: (building) ->
    @town_modal = null
    @name = building.name
    @title = building.title
    @actions = building.actions

    # building container(card)
    @el = $(document.createElement('div'))
      .addClass("building-card building-card-#{building.name}")
      .attr('id', building.id)
      .appendTo('#buildings-list')
    # open building link
    @open_building_el = $(document.createElement('a'))
      .html(@title)
      .attr('id', "open-screen-#{building.name}")
      .data('id', building.name)
      .appendTo(@el)
    @level_observer = new LevelObserver(@open_building_el, building.level, building.max_level)
    @time_observer = new TimeObserver(@el, building.ttb_string, building.status)
    @cost_observer = new CostObserver(@el, building.cost_res)
    @build_observer = new BuildObserver(@el, building.build_label, building.status, building.name)
    switch building.status
      when App.building_states['BUILDING_STATE_GROUND']
        @el.addClass('building-ground')
      when App.building_states['BUILDING_STATE_IN_PROGRESS']
        @el.addClass('building-in-progress')
      when App.building_states['BUILDING_STATE_COMPLETE']
        @el.addClass('building-built')
      when App.building_states['BUILDING_STATE_CAN_UPGRADE']
        @el.addClass('building-can-upgrade')

  update: (building) ->
    @level_observer.update(building.level)
    @time_observer.update(building.ttb_string, building.status)
    @cost_observer.update(building.cost_res)
    @build_observer.update(building.build_label, building.status)
    @actions = building.actions
    switch building.status
      when App.building_states['BUILDING_STATE_GROUND']
        @el
          .removeClass('building-in-progress')
          .removeClass('building-built')
          .addClass('building-ground')
        # @town_modal.close_building() if open_building is current
        # if @town_modal
        #   @remove_open_handler()
        return
      when App.building_states['BUILDING_STATE_IN_PROGRESS']
        @el
          .removeClass('building-ground')
          .addClass('building-in-progress')
      when App.building_states['BUILDING_STATE_COMPLETE']
        @el
          .removeClass('building-ground')
          .removeClass('building-in-progress')
          .addClass('building-built')
      when App.building_states['BUILDING_STATE_CAN_UPGRADE']
        @el
          .removeClass('building-ground')
          .removeClass('building-in-progress')
          .addClass('building-can-upgrade')
      # if @town_modal
      #   @init_open_handler()

  ##
  # @param {TownModal} modal
  # @param {object} building
  set_town_modal: (modal, building) ->
    _this = this
    @town_modal = modal
    @init_open_handler()

  init_open_handler: () ->
    @open_building_el
      .click(() =>
        @open_building()
      )

  remove_open_handler: () ->
    @open_building_el
      .off('click')

  add_cost: (res, q) ->
    $(document.createElement('div'))
      .addClass('resource cost')
      .addClass(res)
      .attr('title', App.resource_info[res].title + ' ' + q)
      .html(
        $(document.createElement('div'))
          .addClass('resource-q')
          .html(q)
      )

  open_building: () ->
    @town_modal.remove_building_inner()
    @town_modal.append_title(@title)
    @town_modal.set_building_description(@name)
    for i, action of @actions
      if action.on
        $(document.createElement('div'))
          .addClass('card')
          .append(
            $(document.createElement('div'))
              .html(action.title)
          )
          .append(
            $(document.createElement('div'))
              .addClass('card-cost')
              .html(
                @add_cost(res, q) for res, q of action.cost
              )
          )
          .append(
            $(document.createElement('button'))
              .html(action.label)
              .click(@action_cb(action))
          )
          .appendTo('.modal.town .modal-building-actions-inner')

  action_cb: () ->
    console.error('Override me!')

class BarracsCard extends BuildingCard
  action_cb: (action) ->
    () =>
      App.hire_unit(action.unit_type)


class TavernCard extends BuildingCard
  action_cb: (action) ->
    () =>
      App.hire_unit(action.unit_type)

class RoadsCard extends BuildingCard;

class FactoryCard extends BuildingCard;

class SawmillCard extends BuildingCard;

class QuarryCard extends BuildingCard;

window.BuildingCard = BuildingCard
