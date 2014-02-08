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

requirejs ['main'], (Main) ->
  Main()
