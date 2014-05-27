## helper functions
# very shallow merge
extend = (source, dest) ->
  for key, value of dest
    source[key] = value
  null

clone = (obj)->
  twin = null
  if isArray obj
    twin = obj.slice()
  else
    twin = {}
    for key, value of obj
      twin[key] = value
  twin

isArray = (obj) ->
  toString.call(obj).indexOf('Array') isnt -1

random = (min, max) ->
  unless max?
    max = min
    min = 0
  min + Math.floor(Math.random() * (max - min + 1))

shuffle = (array) ->
  shuffled = []
  for obj, index in array
    rand = random(index++)
    shuffled[index - 1] = shuffled[rand]
    shuffled[rand] = obj
  shuffled

idCount = 0
uniqueId = (prefix) ->
  id = ++idCounter + ''
  if prefix then prefix + id else id

## Events mixin
#  largely copied from Backbone
Cosmo.Events =
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

window.Word = class Word
  toAttributes:
    id: -> @get('word')

  constructor: (@attributes={}) -> extend(this, Cosmo.Events)

  set: (attr, val) ->
    if typeof attr is 'object'
      for key, val of attr
        @attributes[key] = val
        @trigger "change #{key}"
    else
      @attributes[attr] = val
      @trigger "change #{attr}"
    @trigger 'change'
    undefined

  get: (attr) -> @attributes[attr] or @toAttributes[attr].call(this)

  clone: -> new @constructor(clone(@attributes))

  toJSON: -> clone(@attributes)

  save: (attrs=null, {success, error}={}) ->
    @set attrs if attrs?
    Tutor.get('db').set @toJSON(), (err) =>
      if error
        error?.call this, this
      else
        @trigger 'save'
        success?.call this, this

  destroy: ->
    Tutor.get('db').remove @get('id')
    @trigger 'destroy'

window.Words = class Words
  length: 0

  constructor: (collection=[]) ->
    extend this, Cosmo.Events
    @collection = []
    for word in collection
      word = new Word(word)
      # TODO: work on whole context thing
      @listenTo word, 'destroy', @remove, this
      @collection.push word
    @length = @collection.length

  each: (callback) ->
    for word in @collection
      callback.call(this, word)

  first: -> @collection[0]

  last: -> @collection[@collection.length - 1]

  where: (query={}) ->
    results = []
    if query is {}
      return results
    else
      for word in @collection
        match = true
        for attr, value of query
          if word.get(attr) isnt value
            match = false
            break
        results.push word if match
      results

  findWhere: (query={}) ->
    @where(query)[0]

  remove: (word) ->
    toKeep = []
    for model in @collection
      toKeep.push model if word is not model
    @collection = toKeep
    @length = @collection.length
    @trigger 'change'

  push: (word) ->
    @listenTo word, 'destroy', @remove
    @collection.push word
    @length = @collection.length
    @trigger 'change'

  shift: ->
    length = @collection.length - 1
    @collection.shift()
    @trigger 'change'

  shuffle: ->
    toShuffle = []
    for word in @collection
      toShuffle.push word.toJSON()
    shuffled = shuffle(toShuffle)
    new @constructor(shuffled)

  _isEmpty: (obj) ->
    empty = true
    for key, value of obj
      empty = false
      break
    empty
