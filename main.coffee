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

  addWords: -> @render new Views.addWords

  studyWords: (words) ->
    if words?
      @render new Views.study(collection: words)
    else
      @render new Views.preStudy

  edit: ->
    @get('lawnchair').all (words) =>
      if words.length
        words = new Words(words)
        @render new Views.editWords(collection: words)
      else
        Messenger().post
          message: "There are no words to edit"
          type: ''

  menu: (view) ->
    @regions.sidebar.html view

window.Tutor = new Tutor().start()
