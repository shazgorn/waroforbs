class StateObserver
  constructor: (target, status) ->
    @target = target
    @status = status

  update: (status) ->
    if @status != status
      @status = status
      @set_status()

  set_status: () ->
    switch @status
      when App.building_states['BUILDING_STATE_GROUND']
        @el
          .removeClass('building-in-progress')
          .removeClass('building-built')
          .addClass('building-ground')
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
