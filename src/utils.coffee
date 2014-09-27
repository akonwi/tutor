## Helper functions, mostly copied from underscore.js

# keep track of ids
idCount = 0

window._ =
  # very shallow merge of objects
  # actually extends classes
  extend: (source, ext) ->
    if !!source.constructor.prototype
      for k, v of ext
        source.constructor::[k] = v
    else
      for k, v of ext
        source::[k] = v
    null

  clone: (obj)->
    twin = null
    if @isArray obj
      twin = obj.slice()
    else
      twin = {}
      for key, value of obj
        twin[key] = value
    twin

  isArray: (obj) ->
    toString.call(obj).indexOf('Array') isnt -1

  toArray: (obj) ->
    array = []
    for key, value of obj
      array.push value
    array

  random: (min, max) ->
    unless max?
      max = min
      min = 0
    min + Math.floor(Math.random() * (max - min + 1))

  shuffle: (array) ->
    shuffled = []
    for obj, index in array
      rand = @random(index++)
      shuffled[index - 1] = shuffled[rand]
      shuffled[rand] = obj
    shuffled

  uniqueId: (prefix) ->
    id = idCount + ''
    if prefix then prefix + id else id
