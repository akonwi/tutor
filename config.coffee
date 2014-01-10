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

  ## Adding a method to underscore that removes beginning and ending whitespace
  #  TODO: implement this
  _.mixin
    trim: (string) ->
      copy = _.clone(string)

  #db.remove {}, (err) ->
    #console.log "cleared database"

  ## Launch the app
  require './main'
