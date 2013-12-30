global.Backbone = window.Backbone
global.Marionette = window.Marionette
global.Handlebars = window.Handlebars
global.$ = window.jQuery
global._ = window._

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
          type: 'selected'
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

    $.fn.form.settings.rules.selected = (value) ->
      not _.isEmpty value

    dropdown = @$el.find('.ui.selection.dropdown')
    dropdown.dropdown()

    # apply validation rules
    form = @$el.find('.ui.form')
    form.form(rules, inline: true, on: 'blur')

    # TODO:
    #   $(form).on 'submit', ->
    #     check $(dropdown).getValue()
    #       show error popup if value is empty
    #       do nothing if value is valid
    #form.form 'setting', onSuccess: ->
    #  if not _.isString dropdown.dropdown('get value')


global.App = new Marionette.Application
App.addRegions
  container: '#container'

App.addInitializer (options) ->
  @router = new Router()

App.on 'initialize:after', ->
  @router.go 'home'

App.start()
