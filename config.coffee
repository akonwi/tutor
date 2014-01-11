path = require 'path'
Datastore = require 'nedb'
## Put client side stuff into the global scope
global.Backbone = window.Backbone
global.Marionette = window.Marionette
global.Handlebars = window.Handlebars
global.$ = window.jQuery
global._ = window._

require('backbone.nedb')(Backbone)

## This is essentially just a collection of words
global.db = new Datastore(filename: path.join(gui.App.dataPath, 'words.db'))
db.loadDatabase (err) ->
  console.log(err) if err?

  ## Adding a method to underscore that removes ending whitespace
  #  TODO: implement this
  _.mixin
    trim: (string) ->
      if _.last(string) is ' '
        _(_.initial(string)).trim()
      else
        string.join ''

  #db.remove {}, (err) ->
    #console.log "cleared database"

  # Setup app for everything that will use it
  global.App = new Marionette.Application
  ## Launch the app
  require './main'
