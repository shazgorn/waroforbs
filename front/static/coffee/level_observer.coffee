class LevelObserver
  # next level
  ##
  # @param {string} target
  # @param {Object} level
  constructor: (target, level, max_level) ->
    @target = target
    @level = level
    @max_level = max_level
    @building_level_el = null
    @building_next_level_el = null
    @add_level()

  update: (level) ->
    if level != @level
      @level = level
      @add_level()

  add_level: () ->
    if @level > 1
      unless @building_level_el
        @building_level_el = $(document.createElement('span'))
          .addClass('current-level')
          .appendTo(@target)
      @building_level_el
        .html(' [' + @level + ']')
    if @level > 0
      unless @building_next_level_el
        @building_next_level_el = $(document.createElement('span'))
          .addClass('next-level')
          .appendTo(@target)
      if @level + 1 <= @max_level
        @building_next_level_el
          .html(' [' + (@level + 1) + ']')
      else
        @building_next_level_el
          .html('')


window.LevelObserver = LevelObserver
