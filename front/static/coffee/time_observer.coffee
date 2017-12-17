class TimeObserver
  constructor: (target, ttb, status) ->
    @target = target
    @ttb = ttb
    @status = status
    @building_time = null
    @add_ttb()
    @start_cd()

  update: (ttb, status) ->
    if @ttb != ttb
      @ttb = ttb
      @add_ttb()
    @status = status
    @start_cd()

  start_cd: () ->
    if @status == App.building_states['BUILDING_STATE_IN_PROGRESS']
      @start_building_countdown()

  add_ttb: () ->
    unless @building_time
      @building_time = $(document.createElement('div'))
        .addClass('building-time')
        .appendTo(@target)
    @building_time.html(@ttb)

  start_building_countdown: () ->
    clearInterval(@interval)
    @interval = setInterval(
      () =>
        if @status != App.building_states['BUILDING_STATE_IN_PROGRESS']
          clearInterval(@interval)
          return
        ms = @building_time.html().split(':')
        m = ms[0] * 1
        s = ms[1] * 1
        if s == 0
          if m == 0
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

window.TimeObserver = TimeObserver
