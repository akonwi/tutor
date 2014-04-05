define ['views', 'word'], (Views, WordModule) ->
  Words = WordModule.collection

  class Router
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
      Tutor.container.show view

    menu: (view) ->
      Tutor.sidebar.show view

  return ->
    window.Tutor = new Marionette.Application
    Tutor.addRegions
      container: '#container'
      sidebar: '#side-menu'
    Tutor.addInitializer (options) ->
      @router = new Router
      @lawnchair = new Lawnchair
        name: 'words'
        record: 'word'
        , ->
          @all (words) ->
            Tutor.words = new Words(words)
    Tutor.on 'initialize:after', ->
      @router.go 'home'
    Tutor.start()
