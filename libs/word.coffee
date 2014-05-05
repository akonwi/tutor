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

window.Word = class Word
  toAttributes:
    id: -> @get('word')

  constructor: (@attributes={}) ->

  set: (attr, val) ->
    if typeof attr is 'object'
      for key, val of attr
        @attributes[key] = val
    else
      @attributes[attr] = val
    undefined

  get: (attr) -> @attributes[attr] or @toAttributes[attr].call(this)

  clone: -> new @constructor(clone(@attributes))

  toJSON: -> clone(@attributes)

  save: (attr, val, options) ->
    @set attr, val
    Tutor.get('db').set @toJSON(), (err) ->
      if err?
        options.error?(model)
      else
        options.success?(model)

  destroy: -> Tutor.get('db').remove @get('id')

window.Words = class Words
  length: 0

  constructor: (collection=[]) ->
    @collection = []
    for word in collection
      @collection.push new Word(word)
    @length = @collection.length

  each: (callback) ->
    console.log "this is", this
    console.log "callback is", callback
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

  shift: ->
    length = @collection.length - 1
    @collection.shift()

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
