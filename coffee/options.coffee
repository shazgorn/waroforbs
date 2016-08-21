class Options
  constructor: () ->
    @log_height = 100
    @map_height = 13
    @map_width = 13
    @all_cells = false
    @show_grid = false
    @init_options()

  init_options: () ->
    _this = this
    @bind()

    @option('log_height', 5, 'int', (t) ->
      if t.log_height > 10
        t.log_height = 10
      $('#log').height(t.log_height * 20)
    , true)
    map_callback = (t) -> App.map.set_size(t.map_height, t.map_width)
    @option('map_height', 13, 'int', map_callback, false)
    @option('map_width', 13, 'int', map_callback, false)
    @option('all_cells', false, 'bool', null, false)
    @option('show_grid', false, 'bool', (t) ->
      if t.show_grid
        $('#map').addClass("bordered-cells")
      else
        $('#map').removeClass("bordered-cells")
    , true)

  option: (key, d, type, callback, trigger) ->
    _this = this
    if type == 'int'
      @load_int(key, d)
    else if type == 'bool'
      @load_bool(key, d)
    console.log('option', key, this[key], trigger)
    if callback && trigger
      callback(_this)
    $('#' + key).change(() ->
      if type == 'int'
        _this.imp_int(key)
      else if type == 'bool'
        _this.imp_bool(key)
      if callback
        callback(_this)
    )

  set: (key, value) ->
    localStorage.setItem(key, value)
    this[key] = value

  # Import form -> Options, localStorage
  imp: (key) ->
    $('#' + key).val()

  imp_int: (key) ->
    @set(key, parseInt(@imp(key)))

  imp_bool: (key) ->
    @set(key, $('#' + key).prop("checked"))

  # Load data Options -> Form
  load: (key) ->
    @get(key)
    $('#' + key).val(this[key])

  load_int: (key) ->
    @get_int(key)
    $('#' + key).val(this[key])

  load_bool: (key) ->
    val = @get_bool(key)
    console.log('load_bool', key, val)
    $('#' + key).prop("checked", this[key])

  # Get from localStorage -> Options
  get: (key) ->
    val = localStorage.getItem(key)
    console.log('get', key, val)
    this[key] = val

  get_bool: (key, d) ->
    val = @get(key) == 'true' ? true : false
    console.log('get_bool', key, val)
    this[key] = val

  get_int: (key, d = 0) ->
    val = parseInt(@get(key))
    if !val || isNaN(val)
      val = d
    this[key] = val

  # Bind event hanlders to buttons
  bind: () ->
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

this.Options = Options
