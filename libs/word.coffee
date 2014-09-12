## Helper functions, mostly copied from underscore.js

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
EventSystem =
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

## Model for individual 'words'
#
# Can be instantiated with a set of initial attributes,
#   which must include an 'id'.
#
# Events emitted:
#   change
#   change [attribute]
#   save
#   destroy
window.Word = class Word
  constructor: (@attributes={ id: null }) -> extend(this, EventSystem)

  # Set attributes, but 'id' can't be overridden if it exists
  set: (attr, val) ->
    changed = false
    if typeof attr is 'object'
      for key, val of attr
        if (key is 'id' and not @attributes.id?) or key is not 'id'
          @attributes[key] = val
          @trigger "change #{key}"
          changed = true
    else
      @attributes[attr] = val
      @trigger "change #{attr}"
      changed = true
    if changed?
      @trigger 'change'
      return true
    else
      return false

  get: (attr) -> @attributes[attr]

  # complete overwrite of @attributes
  flush: (@attributes) ->

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

## Model for a collection of words
#
# Can be instantiated with an initial array of words.
#
# Events emitted:
#   change
window.Words = class Words
  length: 0

  constructor: (collection=[]) ->
    extend this, EventSystem
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
      new Words(results)

  findWhere: (query={}) ->
    @where(query).first()

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
    shifted = @collection.shift()
    @trigger 'change'
    return shifted

  hasNext: -> if @collection.length >= 1 then true else false

  shuffle: ->
    toShuffle = []
    for word in @collection
      toShuffle.push word.toJSON()
    shuffled = shuffle(toShuffle)
    new Words(shuffled)
