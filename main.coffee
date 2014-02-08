define ['views', 'word'], (Views, WordModule) ->
  Words = WordModule.collection

  # Router is going to do what Backbone's router does but because node-webkit
  #   routing works by serving individual html files, this router will skip
  #   url paths entirely and just use functions directly(kind of a rails-y DSL).
  #   These functions will act as controllers and should call @render to display
  #   the relevant view
  class Router
    # @params page string name of page to visit
    # @params args optional arguments used by methods as needed
    go: (page, args...) ->
      if this[page]?
        this[page]?(args[0], args[1])
      else
        @home()

    home: ->
      @render new Views.home()

    addWords: ->
      @render new Views.addWords(collection: Tutor.words)

    studyWords: (words) ->
      if words?
        @render new Views.study(collection: words)
      else
        Tutor.lawnchair.all (words) =>
          words = new Words(words)
          @render new Views.preStudy(collection: words)

    render: (view) ->
      Tutor.container.show view

  return ->
    window.Tutor = new Marionette.Application
    Tutor.addRegions
      container: '#container'
    Tutor.addInitializer (options) ->
      @router = new Router
      @lawnchair = new Lawnchair name: 'words', record: 'word', ->
        @all (words) -> Tutor.words = new Words(words)
    Tutor.on 'initialize:after', ->
      @router.go 'home'
    Tutor.start()
