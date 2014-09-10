$(document).ready ->
  Messenger.options =
    extraClasses: 'messenger-fixed messenger-on-top'
    theme: 'ice'

  class App extends Cosmo.Router
    container: document.getElementById('container')

    initialize: ->
      @set 'db', new Store
      @get('db').all (items) =>
        collection = new Words(items)
        @set 'words', collection
        # when collection changes(add/remove) update it
        collection.on 'change', (newCollection) =>
          @set 'words', newCollection

    render: (component) ->
      React.renderComponent(component, @container)

    home: -> @render new Views.Home

    addWords: -> @render new Views.addWords

    preStudy: -> @render new Views.PreStudy

    study: (type) ->
      collection = @get('db').all (words) =>
        words = new Words(words)
        if type is 'all'
          # @render...
        else
          words = words.where type: type
          # @render...
        console.log words

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
      #if view is null
        #@regions.sidebar.hide()
      #else
        #@regions.sidebar.html view
        #@regions.sidebar.show()

  window.Tutor = new App().start()
