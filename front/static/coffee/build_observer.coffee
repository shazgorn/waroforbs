class BuildObserver
  constructor: (target, build_label, status, name) ->
    @target = target
    @build_label = build_label
    @status = status
    @name = name
    @build_el = null
    @add_label()
    @add_cb()

  update: (build_label, status) ->
    if @build_label != build_label
      @build_label = build_label
      @add_label()
    if @status != status
      @status = status
      @add_cb()

  add_cb: () ->
    switch @status
      when App.building_states['BUILDING_STATE_GROUND']
        @bind()
      when App.building_states['BUILDING_STATE_IN_PROGRESS'], App.building_states['BUILDING_STATE_COMPLETE']
        @unbind()
      when App.building_states['BUILDING_STATE_CAN_UPGRADE']
        @rebind()

  add_label: () ->
    unless @build_el
      @build_el = $(document.createElement('button'))
        .addClass('build-button')
        .appendTo(@target)
    @build_el.html(@build_label)

  unbind: () ->
    @build_el.off('click')

  bind: () ->
    @build_el
      .click(() =>
        App.build(@name)
      )

  rebind: () ->
    @unbind()
    @bind()

window.BuildObserver = BuildObserver
