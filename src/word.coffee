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
  constructor: (@attributes={ id: null }) -> _.extend this, Emitter

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

  clone: -> new @constructor(_.clone(@attributes))

  toJSON: -> _.clone(@attributes)

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
    _.extend this, Emitter
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
    shifted = @collection.shift()
    length = @collection.length
    @trigger 'change'
    return shifted

  hasNext: -> if @collection.length >= 1 then true else false

  # in place shuffle
  shuffle: ->
    @collection = _.shuffle(@collection)
    #toShuffle = []
    #for word in @collection
      #toShuffle.push word.toJSON()
    #shuffled = shuffle(toShuffle)
    #new Words(shuffled)
    this
