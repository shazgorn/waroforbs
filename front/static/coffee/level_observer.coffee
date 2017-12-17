class LevelObserver
  ##
  # @param {Object} cost
  # @param {string} target
  constructor: (target, level) ->
    @target = target
    @level = level
    @building_level_el = null
    @add_level()

  update: (level) ->
    if level != @level
      @level = level
      @add_level()

  add_level: () ->
    if @level > 1
      unless @building_level_el
        @building_level_el = $(document.createElement('span'))
          .appendTo(@target)
      @building_level_el
        .html(' [' + @level + ']')


window.LevelObserver = LevelObserver
