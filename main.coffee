Messenger.options =
  extraClasses: 'messenger-fixed messenger-on-top'
  theme: 'ice'

class Router
  constructor: -> @initializers = []

  # pass a block of code to run on ::start call
  init: (toDo) ->
    @initializers.push toDo
    this

  # do initialization stuff and then start app routing
  # TODO: Do some url management
  start: ->
    init.apply(this) for init in @initializers
    @go 'home'
    this

  # Takes an object with names and jquery selectors
  addRegions: (regions) ->
    for key, value of regions
      this[key] = $(value)
    this

  # set the value and return it when done
  set: (key, val) ->
    if val?
      this[key] = val
    else
      this[key] = null
    this

  get: (key) -> this[key]

  go: (page, args...) ->
    if this[page]?
      this[page]?(args[0], args[1])
    else
      @home()

  home: -> @render new Views.home

  addWords: -> @render new Views.addWords(collection: Tutor.words)

  studyWords: (words) ->
    if words?
      @render new Views.study(collection: words)
    else
      Tutor.lawnchair.all (words) =>
        words = (new Words(words)).shuffle()
        @render new Views.preStudy(collection: words)

  edit: ->
    Tutor.lawnchair.all (words) =>
      words = new Words(words)
      @render new Views.editWords(collection: words)

  render: (view) ->
    # @sidebar.reset()
    @container.html view

  menu: (view) ->
    Tutor.sidebar.show view

window.Tutor = new Router()
  .addRegions
    container: '#container'
    sidebar: '#side-menu'
  .init ->
    @set 'lawnchair', new Lawnchair(name: 'words', record: 'word')
  .init ->
    app = this
    @get 'lawnchair'
      .all (words) ->
        app.set 'words', new Words(words)
  .start()
