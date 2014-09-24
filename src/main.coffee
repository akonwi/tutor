document.addEventListener 'DOMContentLoaded', ->
  Messenger.options =
    extraClasses: 'messenger-fixed messenger-on-top'
    theme: 'ice'

  class App extends Router
    container: document.getElementById('container')
    nav: document.getElementsByTagName('nav')[0]

    initialize: ->
      $.extend(this, Emitter)
      @set 'db', new Store
      @get('db').all (items) =>
        collection = new Words(items)
        @set 'words', collection
        collection.on 'change', (newCollection) =>
          @set 'words', newCollection

    render: (component) ->
      React.renderComponent(component, @container)

    index: ->
      @render new Views.Home
      React.renderComponent(new Views.NavBar, @nav)

    addWords: -> @render new Views.AddWords

    preStudy: -> @render new Views.PreStudy

    study: (type) ->
      @get('db').all (words) =>
        words = new Words(words)
        unless type is 'all'
          words = words.where type: type
        if words.length is 0
          @index()
        else
          @render new Views.Study(collection: words.shuffle())

    editWords: ->
      @get('db').all (words) =>
        if words.length isnt 0
          words = new Words(words)
          @render new Views.EditWords(collection: words)
        else
          Messenger().post
            message: "There are no words to edit"
            type: ''

  window.Tutor = new App().start()
