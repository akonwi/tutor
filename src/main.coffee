document.addEventListener 'DOMContentLoaded', ->
  Messenger.options =
    extraClasses: 'messenger-fixed messenger-on-top'
    theme: 'ice'

  # easy reference url objects for the menu
  URLS =
    home:
      route: 'index'
      text: 'Home'
    study:
      route: 'preStudy'
      text: 'Study'
    edit:
      route: 'editWords'
      text: 'Edit'
    add:
      route: 'addWords'
      text: 'Add'

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
      React.renderComponent(new Views.NavBar(app: this), @nav)

    render: (component) -> React.renderComponent(component, @container)

    index: ->
      @render new Views.Home
      @trigger 'change:menu', []

    addWords: ->
      @render new Views.AddWords
      @trigger 'change:menu', [URLS.home, URLS.study, URLS.edit]

    preStudy: ->
      @render new Views.PreStudy
      @trigger 'change:menu', [URLS.home, URLS.add, URLS.edit]

    study: (type) ->
      @get('db').all (words) =>
        words = new Words(words)
        unless type is 'all'
          words = words.where type: type
        if words.length is 0
          @index()
        else
          @render new Views.Study(collection: words.shuffle())
          @trigger 'change:menu', [URLS.home, URLS.add, URLS.edit]

    editWords: ->
      @get('db').all (words) =>
        if words.length isnt 0
          words = new Words(words)
          @render new Views.EditWords(collection: words)
          @trigger 'change:menu', [URLS.home, URLS.add, URLS.study]
        else
          Messenger().post
            message: "There are no words to edit"
            type: ''

  window.Tutor = new App().start()
