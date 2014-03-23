requirejs.config
  baseUrl: 'libs'
  paths:
    main: '../main'

requirejs ['main'], (Main) ->
  Messenger.options =
    extraClasses: 'messenger-fixed messenger-on-top'
    theme: 'ice'
  Main()
