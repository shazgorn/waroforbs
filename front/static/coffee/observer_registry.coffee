class ObserverRegistry
  @registry: {}
  @add: (key, observer) ->
    @registry[key] = observer

  @get: (key) ->
    @registry[key]

  @publish: (event, data) ->
    for key, observer of @registry
      observer.notify(event, data)

window.ObserverRegistry = ObserverRegistry
