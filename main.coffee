$(document).ready ->
  Messenger.options =
    extraClasses: 'messenger-fixed messenger-on-top'
    theme: 'ice'

  class App extends Cosmo.Router
    initialize: ->
      @addRegions
        container: '#container'
        sidebar: '#side-menu'
      @set 'db', new Store
      @get('db').all (items) =>
        collection = new Words(items)
        @set 'words', collection
        # when collection changes(add/remove) update it
        collection.on 'change', (newCollection) =>
          @set 'words', newCollection

      # setup semantic sidebar
      @regions.sidebar.sidebar().toggle()

    home: ->
      @regions.sidebar.hide()
      @render new Views.home

    addWords: -> @render new Views.addWords

    studyWords: (words) ->
      if words?
        @render new Views.study(collection: words)
      else
        @render new Views.preStudy

    edit: ->
      @get('db').all (words) =>
        if words.length isnt 0
          words = new Words(words)
          @render new Views.editWords(words)
        else
          Messenger().post
            message: "There are no words to edit"
            type: ''

    # if no view, hide the sidebar
    menu: (view=null) ->
      if view is null
        @regions.sidebar.hide()
      else
        @regions.sidebar.html view
        @regions.sidebar.show()

  window.Tutor = new App().start()
