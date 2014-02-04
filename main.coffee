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
      @render new Views.addWords(collection: @words())

    studyWords: (words) ->
      if words?
        @render new Views.study(collection: words)
      else
        @render new Views.preStudy(collection: @words())

    render: (view) ->
      App.container.show view

    words: ->
      App.words

  return ->
    window.App = new Marionette.Application
    App.addRegions
      container: '#container'
    App.addInitializer (options) ->
      @router = new Router
      @words = new Words
      #@words = new Words(_.shuffle(db.getAllData()))
    App.on 'initialize:after', ->
      @router.go 'home'
    App.start()
