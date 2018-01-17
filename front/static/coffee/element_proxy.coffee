class ElementProxy
  constructor: (element, value) ->
    @element = element
    @value = value

  update: (value) ->
    if @value != value
      @value = value
      $(@element).html(value)

window.ElementProxy = ElementProxy
