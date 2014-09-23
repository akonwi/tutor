## Events mixin
#  largely copied from Backbone
window.EventSystem =
  on: (name, callback, context=this) ->
    @events = @events or {}
    todos = @events[name] or []
    todos.push {callback, context}
    @events[name] = todos
    this

  once: (name, callback, context) ->
    single = =>
      @off name, callback
      callback.apply this, arguments

    single.callback = callback
    @on name, single

  off: (name=null, callback=null) ->
    if name is null
      @events = {}
    else if callback is null
      delete @events[name]
    else
      toKeep = []
      todos = @events[name]
      for todo in todos
        toKeep.push todo if todo.callback is not callback
      if not toKeep.length then delete @events[name] else @events[name] = toKeep
    this

  trigger: (event) ->
    return if not @events?[event]
    for {callback, context} in @events[event]
      callback.call context, this
    this

  listenTo: (obj, name, callback, context=this) ->
    @listeningTo = @listeningTo or {}
    id = obj.listenId = uniqueId('l')
    @listeningTo[id] = obj
    obj.on name, callback, context

  listenToOnce: (obj, name, callback, context=this) ->
    @listeningTo = @listeningTo or {}
    id = obj.listenId = uniqueId('l')
    @listeningTo[id] = obj
    obj.once name, callback, context

