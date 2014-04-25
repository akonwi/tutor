Messenger.options =
  extraClasses: 'messenger-fixed messenger-on-top'
  theme: 'ice'

class Tutor extends Cosmo.Router
  initialize: ->
    @addRegions
      container: '#container'
      sidebar: '#side-menu'
    @set 'lawnchair', new Lawnchair(name: 'words', record: 'word')
    @get 'lawnchair'
    .all (words) =>
      @set 'words', new Words(words)

  home: -> @render new Views.home

  addWords: -> @render new Views.addWords()

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
    @regions.container.html view

  menu: (view) ->
    Tutor.sidebar.show view

window.Tutor = new Tutor().start()
