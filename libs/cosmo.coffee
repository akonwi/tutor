window.Cosmo = {}

# All apps should be an extended instance of this class
class Cosmo.Router
  # app regions, assumes main content goes in a div#container
  regions:
    container: '#container'

  constructor: -> @initializers = []

  initialize: ->

  # pass a block of code to run on ::start call
  # TODO: remove?
  init: (toDo) ->
    @initializers.push toDo
    this

  # do initialization stuff and then start app routing
  # TODO: Do some url management
  start: ->
    init.apply(this) for init in @initializers
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

  go: (page, args...) ->
    console.log 'page is', page
    console.log 'args are', args
    if this[page]?
      this[page]?(args[0], args[1])
    else
      @home()

  render: (view) -> @regions.container.html view
