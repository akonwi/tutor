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
    this[page]?(args) || window.alert 'no dice'

  home: ->
    $('#container').html new HomeView().render().el

class HomeView extends Marionette.Layout
  template: Handlebars.compile $('#home-view').html()

app = new Router()
app.go 'home'
