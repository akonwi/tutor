WordModule = require('./libs/word')
Word = WordModule.model
Words = WordModule.collection

# Router is going to do what Backbone's router does but because node-webkit
#   loads each html file, this router will skip url paths entirely and
#   just use functions directly(kind of a rails-y DSL). These functions will
#   act as controllers and should call render to display the relevant view
class Router
  # @params page string name of page to visit
  # @params args optional arguments used by methods as needed
  go: (page, args...) ->
    if this[page]?
      this[page]?(args)
    else
      @home()

  home: ->
    @render new HomeView()

  addWords: ->
    @render new AddWordsView()

  render: (view) ->
    App.container.show view

class HomeView extends Marionette.Layout
  template: Handlebars.compile $('#home-view').html()
  events:
    'click #add-words-button': 'addWords'

  addWords: (e) ->
    e.preventDefault()
    App.router.go 'addWords'

class AddWordsView extends Marionette.Layout
  template: Handlebars.compile $('#add-words-view').html()

  render: ->
    @$el.html @template()
    @initialize_form()
    this

  initialize_form: ->
    rules =
      type:
        identifier: 'type'
        rules: [
          type: 'empty'
          prompt: 'Need a type'
        ]
      word:
        identifier: 'word'
        rules: [
          type: 'empty'
          prompt: "Can't have a blank entry"
        ]
      definition:
        identifier: 'definition'
        rules: [
          type: 'empty'
          prompt: 'Need a definition'
        ]

    # Overriding the default 'empty' rule for form validation
    $.fn.form.settings.rules.empty = (value) ->
      not _.isEmpty value

    dropdown = @$el.find('.ui.selection.dropdown')
    dropdown.dropdown()

    # apply validation rules
    form = @$el.find('.ui.form')
    form.form(rules, inline: true, on: 'blur')

    # handle on success submission
    form.form 'setting',
      onSuccess: ->
        # TODO: Create word model and database
        attr = {}
        attr.type = dropdown.dropdown 'get value'
        attr.word = form.form('get field', 'word').val()
        attr.definition = form.form('get field', 'definition').val()

        word = new Word(attr)

global.App = new Marionette.Application
App.addRegions
  container: '#container'

App.addInitializer (options) ->
  @router = new Router()

App.on 'initialize:after', ->
  @router.go 'home'

App.start()
