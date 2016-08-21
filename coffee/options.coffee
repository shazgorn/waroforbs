class Options
  constructor: () ->
    @log_height = 100
    @mhc = 13
    @mwc = 13
    @init_options()

  set: (key, value) ->
    localStorage.setItem(key, value)
    this[key] = value

  init_options: () ->
    _this = this
    $('#open-options').click(() ->
      $('.modal').hide()
      $('.modal.options').show()
    )
    $('#open-help').click(() ->
      $('.modal').hide()
      $('.modal.help').show()
    )
    $('#exit').click(() ->
      localStorage.setItem('token', '')
      location.pathname = '/'
    )
    # log_heigth
    @log_height = localStorage.getItem('log_height')
    unless @log_height
      @log_height = 100
    $('#log').height(@log_height)
    $('#log_height').val(@log_height)
    $('#save-options').click(() =>
      @log_height = $('#log_height').val()
      @set('log_height', @log_height)
      $('#log').height(@log_height)
    )
    # map height cells
    @mhc = parseInt(localStorage.getItem('mhc'))
    if !@mhc || isNaN(@mhc)
      @mhc = 13
      @set('mhc', @mhc)
    $('#map_height').val(@mhc)

    #map width cells
    @mwc = parseInt(localStorage.getItem('mwc'))
    if !@mwc || isNaN(@mwc)
      @mwc = 13
      @set('mwc', @mwc)
    $('#map_width').val(@mwc)

    $('#map_height').change((e) ->
      _this.set('mhc', parseInt($(this).val()))
      App.map.set_size(_this.mhc, _this.mwc)
    )
    $('#map_width').change((e) ->
      _this.set('mwc', parseInt($(this).val()))
      App.map.set_size(_this.mhc, _this.mwc)
    )

this.Options = Options
