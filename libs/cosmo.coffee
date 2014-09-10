window.Cosmo =
  version: '0.1.0'

# All apps should be an extended instance of this class
class Cosmo.Router
  # overwrite for custom initialization
  initialize: ->

  # do initialization stuff and then start app routing
  # TODO: Do some url management
  start: ->
    @initialize()
    @go 'home'
    this

  # set the value
  # TODO: Return value or this? (to allow chaining)
  set: (key, val) ->
    if val?
      this[key] = val
    else
      this[key] = null
    this

  get: (key) -> this[key]

  # main routing function
  go: (route) ->
    url = route.split('/')
    page = url.shift()
    params = url
    if this[page]?
      this[page]?(params[0], params[1])
    else
      @home()
