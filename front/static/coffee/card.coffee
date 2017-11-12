##
# There can be more cards but for now it is just building`s base class
# Unit card
class Card
  constructor: () ->
    return

##
# Card - some entity in modal window
# In this case it is building box in the town screen
# Created when new building model is fetched, updated when building model has been changed, etc
# Extract(remove) building related logic from TownModalControls and leave rendering tasks only.
# Call town modal controls via model.controls
class BuildingCard extends Card
  @create: (building) ->
    switch building.name
      when "barracs" then building = new BarracsCard(building)

  ###
  # @param {Building} building
  ###
  constructor: (building) ->
    @town_modal = null
    @name = building.name
    @title = building.title
    @actions = building.actions
    # building container(card) with link, time to build, cost and build button
    @el = $('.building-card-template')
      .clone()
      .addClass("building-card-#{building.name}")
      .attr('id', building.id)
      .removeClass('building-card-template')
    # open building link
    @open_building_button = @el.find('.open-building')
      .html(@title)
      .attr('id', "open-screen-#{building.name}")
      .data('id', building.name)
    @building_time = @el.find('.building-time')
      .html(building.ttb_string)
    @building_cost = @el.find('.building-cost')
    for res, count of building.cost_res
      if count
        $(document.createElement('div'))
          .addClass('cost-res')
          .addClass('cost-res-' + res)
          .attr('title', "#{res} #{count}")
          .html(count)
          .appendTo(@building_cost)
    @build = @el.find('.build-button')

    switch building.status
      when App.building_states['BUILDING_STATE_CAN_BE_BUILT']
        @build
          .click(() =>
            App.build(@name)
          )
        @el
          .addClass('building-not-built')
      when App.building_states['BUILDING_STATE_IN_PROGRESS']
        @el
          .addClass('building-in-progress')
        @start_building_countdown()
      when App.building_states['BUILDING_STATE_BUILT']
        @el
          .addClass('building-built')

  update: (building) ->
    @actions = building.actions
    switch building.status
      when App.building_states['BUILDING_STATE_CAN_BE_BUILT']
        return
      when App.building_states['BUILDING_STATE_IN_PROGRESS']
        @el
          .removeClass('building-not-built')
          .addClass('building-in-progress')
          @start_building_countdown()
        @building_time.html(building.ttb_string)
      when App.building_states['BUILDING_STATE_BUILT']
        @el
          .removeClass('building-not-built')
          .removeClass('building-in-progress')
          .addClass('building-built')
        if @town_modal
          @init_open_handler()

  ##
  # @param {TownModal} modal
  # @param {object} building
  set_town_modal: (modal, building) ->
    _this = this
    @town_modal = modal
    if building.status == App.building_states['BUILDING_STATE_BUILT']
      @init_open_handler()

  init_open_handler: () ->
    @el
      .click(() =>
        @open_building()
      )

  start_building_countdown: () ->
    clearInterval(@interval)
    @interval = setInterval(
      () =>
        ms = @building_time.html().split(':')
        m = ms[0] * 1
        s = ms[1] * 1
        if s == 0
          if m == 0
            clearInterval(@interval)
            App.fetch()
            return
          s = 59
          m = m - 1
        else
          s = s - 1
        if s < 10
          s = '0' + s
        @building_time.html(m + ':' + s)
      1000
    )

class BarracsCard extends BuildingCard
  open_building: () ->
    # clean up
    $('.modal-body .modal-building-inner *').remove()
    $('.modal-body .modal-building-actions-inner *').remove()
    $('.modal.town .modal-title').html('Town - ' + @title)
    console.log(@actions)
    for i, action of @actions
      console.log(action)
      $(document.createElement('button'))
        .html(action.label)
        .appendTo('.modal.town .modal-building-actions-inner')
        .click(() =>
          App.hire_infantry()
        )

window.BuildingCard = BuildingCard
