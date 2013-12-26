global.Backbone = window.Backbone
global.Marionette = window.Marionette
global.Handlebars = window.Handlebars
global.$ = window.jQuery
global._ = window._

# Router is going to do what Backbone's router does but because node-webkit
#   loads each html file, this router will skip url paths entirely and
#   just use functions directly(kind of a rails-y DSL)
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

  render: (view) ->
    App.container.show view

class HomeView extends Marionette.Layout
  template: Handlebars.compile $('#home-view').html()

global.App = new Marionette.Application
App.addRegions
  container: '#container'

App.addInitializer (options) ->
  App.router = new Router()

App.on 'initialize:after', ->
  @router.go 'home'

App.start()
