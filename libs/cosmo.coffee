window.Cosmo = {}

# All apps should be an extended instance of this class
class Cosmo.Router
  # app regions, assumes main content goes in a div#container
  regions:
    container: $('#container')

  initialize: ->

  # do initialization stuff and then start app routing
  # TODO: Do some url management
  start: ->
    @initialize()
    @go 'home'
    this

  # Takes an object with names and jquery selectors
  addRegions: (regions) ->
    for key, value of regions
      @regions[key] = $(value)
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
  go: (page, args...) ->
    if this[page]?
      this[page]?(args[0], args[1])
    else
      @home()

  render: (view) -> @regions.container.html view
