path = require 'path'
Datastore = require 'nedb'
## Put client side stuff into the global scope
global.Backbone = window.Backbone
global.Marionette = window.Marionette
global.Handlebars = window.Handlebars
global.$ = window.jQuery
global._ = window._


## This is essentially just a collection of words
global.db = new Datastore
  filename: path.join(gui.App.dataPath, 'words.db')
  autoload: true

db.remove {}, (err) ->
  console.log "cleared database"

require './libs/backbone_config'

## Launch the app
require './main'
