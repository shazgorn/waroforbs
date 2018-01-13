class OptionsModal
  constructor: () ->
    @log_height = 100
    @show_grid = false
    @init_options()

  init_options: () ->
    _this = this
    @bind()
    @option('log_height', 5, 'int', (t) ->
      $('#log').height(t.log_height * 20)
      $('.modal').css('bottom', ((t.log_height + 1) * 20) + 'px')
    , true)
    @option('show_grid', @show_grid, 'bool', (t) ->
      if t.show_grid
        $('#map').addClass("bordered-cells")
      else
        $('#map').removeClass("bordered-cells")
    , true)
    $('#restart').click(() ->
      $('.modal.options').hide()
      App.restart()
    )

  option: (key, d, type, callback, trigger) ->
    _this = this
    if type == 'int'
      @load_int(key, d)
    else if type == 'bool'
      @load_bool(key, d)
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

  enable: (key) ->
    $('#' + key).prop('disabled', false)

  disable: (key) ->
    $('#' + key).prop('disabled', true)

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

  load_int: (key, d) ->
    @get_int(key, d)
    $('#' + key).val(this[key])

  load_bool: (key) ->
    val = @get_bool(key)
    $('#' + key).prop("checked", this[key])

  # Get from localStorage -> Options
  get: (key) ->
    val = localStorage.getItem(key)
    this[key] = val

  get_bool: (key, d) ->
    val = @get(key) == 'true' ? true : false
    this[key] = val

  get_int: (key, d = 0) ->
    val = parseInt(@get(key))
    if val != 0 && val? || isNaN(val)
      val = d
    this[key] = val

  # Bind event hanlders to buttons
  bind: () ->
    $('#open-options').click(() ->
      $('.modal').hide()
      $('.modal.options').show()
    )
    $('.modal.options .close-modal').on 'click', (event) ->
      $('.modal').hide()
    $('#open-help').click(() ->
      $('.modal').hide()
      $('.modal.help').show()
    )
    $('.modal.help .close-modal').on 'click', (event) ->
      $('.modal').hide()
    $('#exit').click(() ->
      localStorage.setItem('token', '')
      location.pathname = '/'
    )

this.Options = OptionsModal
