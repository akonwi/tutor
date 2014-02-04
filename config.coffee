#path = require 'path'
#Datastore = require 'nedb'
## Put client side stuff into the global scope
#global.Backbone = window.Backbone
#global.Marionette = window.Marionette
#global.Handlebars = window.Handlebars
#global.$ = window.jQuery
#global._ = window._

#require('backbone.nedb')(Backbone)

## This is essentially just a collection of words
#global.db = new Datastore(filename: path.join(gui.App.dataPath, 'words.db'))
#db.loadDatabase (err) ->
  #console.log(err) if err?

  ## Adding a method to underscore that removes ending whitespace
  ##  TODO: handle string in the case of an object
  #_.trim = (string) ->
    #unless _.isEmpty string
      #if (_.last(string) is ' ') then @trim(_.initial(string)) else string.join('')
    #else
      #if _.isString(string) then string else ''

  ##db.remove {}, (err) ->
    ##console.log "cleared database"

  ## Setup app for everything that will use it
  #global.App = new Marionette.Application
  ## Launch the app
  #require './main'

requirejs.config
  baseUrl: 'libs'
  paths:
    main: '../main'

App = new Marionette.Application

require ['main'], (Main) ->
  Main()
