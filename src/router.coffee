window.Router = class Router
  # store stuff
  _storage: {}

  # overwrite to run custom setup
  initialize: ->

  # do initialization stuff and then start app routing
  start: ->
    @initialize()
    @go 'index'
    this

  # store a value in router
  #
  # @param key for value
  # @param val value to store
  # @return this instance of Router
  set: (key, val) ->
    if val?
      @_storage[key] = val
    else
      @_storage[key] = null
    this

  # Retrieve stored value
  #
  # @param key to lookup
  # @return value saved under given key or undefined
  get: (key) -> @_storage[key]

  # navigate to a route
  #
  # @param url the 'url' to navigate to
  go: (url) ->
    route = url.split('/')
    page = route.shift()
    params = route
    if this[page]?
      this[page]?(params[0], params[1])
    else
      @index()
