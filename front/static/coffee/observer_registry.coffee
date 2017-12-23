class ObserverRegistry
  @registry: {}
  @add: (key, observer) ->
    if @registry[key]
      throw new Error("#{key} already added to registry")
    @registry[key] = observer

  @get: (key) ->
    @registry[key]

  @publish: (event, data) ->
    for key, observer of @registry
      observer.notify(event, data)

window.ObserverRegistry = ObserverRegistry
